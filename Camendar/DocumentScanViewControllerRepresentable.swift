//
//  DocumentScanViewControllerRepresentable.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI
import VisionKit
import Vision
import Foundation

struct DocumentScanViewControllerRepresentable: UIViewControllerRepresentable {

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentScanViewControllerRepresentable

        init(parent: DocumentScanViewControllerRepresentable) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true, completion: nil)

            if scan.pageCount > 0 {
                let scannedImage = scan.imageOfPage(at: 0)

                parent.performOCR(on: scannedImage) { lines in
                    var allDates = [(Date, String?, Date?, Date?)]() // 型を合わせる
                    for line in lines {
                        let dates = self.parent.findEventDate(text: line)
                        allDates.append(contentsOf: dates) // ここでのエラーは解消される
                    }
                    // メインスレッドでUI更新
                    DispatchQueue.main.async {
                        self.parent.recognizedText = lines.joined(separator: "\n")
                        self.parent.extractedDates = allDates // 正しい型で代入
                    }
                }
            }
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true, completion: nil)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            controller.dismiss(animated: true, completion: nil)
            print("Error scanning document: \(error.localizedDescription)")
        }
    }

    @Binding var recognizedText: String // OCR結果を保持するためのバインディング
    @Binding var extractedDates: [(Date, String?, Date?, Date?)]// 抽出された日付のリスト（[Date]型）

    func findEventDate(text: String) -> [(Date, String?, Date?, Date?)] {
        // 日付と時間の正規表現パターン
        let datePatterns: [(String, String)] = [
            ("[0-9]{4}/(1[0-2]|[1-9])/([1-9]|[1-3][0-9])", "yyyy/MM/dd"),
            ("[0-9]{4}年(1[0-2]|[1-9])月([1-3][0-9]|[1-9])日", "yyyy年M月d日"),
            ("[0-9]{4}-(1[0-2]|[1-9])-([1-3][0-9]|[1-9])", "yyyy-MM-dd")
        ]
        let timePattern = "([01][0-9]|2[0-3]):[0-5][0-9]"

        var details: [(Date, String?, Date?, Date?)] = []

        // 各正規表現パターンでテキストから日付を抽出
        for (pattern, dateFormat) in datePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = dateFormat

                for match in matches {
                    if let dateRange = Range(match.range, in: text) {
                        let dateString = String(text[dateRange])
                        if let date = dateFormatter.date(from: dateString) {
                            let timeRegex = try? NSRegularExpression(pattern: timePattern)
                            let timeMatches = timeRegex?.matches(in: text, range: NSRange(text.startIndex..., in: text))

                            var times: [Date] = []
                            if let timeMatches = timeMatches {
                                let timeFormatter = DateFormatter()
                                timeFormatter.dateFormat = "HH:mm"
                                for timeMatch in timeMatches {
                                    if let timeRange = Range(timeMatch.range, in: text) {
                                        let timeString = String(text[timeRange])
                                        if let time = timeFormatter.date(from: timeString) {
                                            times.append(time)
                                        }
                                    }
                                }
                            }

                            let startTime = times.first
                            let endTime = times.count > 1 ? times[1] : nil
                            let eventName = extractEventName(from: text, around: dateRange)

                            details.append((date, eventName, startTime, endTime))
                        }
                    }
                }
            }
        }
        return details
    }

    func extractEventName(from text: String, around dateRange: Range<String.Index>) -> String? {
        let leftText = String(text[..<dateRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        let rightText = String(text[dateRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)

        // 左右のテキストからさらなる日付や時刻のパターンを除外
        let additionalPattern = "[0-9]{1,2}:[0-9]{2}|[0-9]{2,4}[年/-][0-9]{1,2}[月/-][0-9]{1,2}日?"
        let additionalRegex = try? NSRegularExpression(pattern: additionalPattern)

        let leftEvent = additionalRegex?.stringByReplacingMatches(in: leftText, options: [], range: NSRange(leftText.startIndex..., in: leftText), withTemplate: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let rightEvent = additionalRegex?.stringByReplacingMatches(in: rightText, options: [], range: NSRange(rightText.startIndex..., in: rightText), withTemplate: "").trimmingCharacters(in: .whitespacesAndNewlines)

        var eventName: String? = nil
        if !leftEvent!.isEmpty {
            eventName = leftEvent
        } else if !rightEvent!.isEmpty {
            eventName = rightEvent
        }

        return eventName
    }



    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentScanner = VNDocumentCameraViewController()  // ドキュメントスキャナー
        documentScanner.delegate = context.coordinator  // デリゲートを設定
        return documentScanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // 更新処理をここに記述（必要な場合）
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func performOCR(on image: UIImage, completion: @escaping ([String]) -> Void) {
        guard let cgImage = image.cgImage else {
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        let textRecognitionRequest = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Error recognizing text: \(error.localizedDescription)")
                return
            }

            if let results = request.results as? [VNRecognizedTextObservation] {
                let textBlocks = results.compactMap { observation -> (text: String, bounds: CGRect)? in
                    guard let candidate = observation.topCandidates(1).first else {
                        return nil
                    }
                    return (candidate.string, observation.boundingBox)
                }

                // 隣接するブロックを一行として連結する処理
                var lines: [String] = []
                var currentLine = textBlocks.first?.text ?? ""
                var lastBounds = textBlocks.first?.bounds ?? CGRect.zero

                for block in textBlocks.dropFirst() {
                    if abs(block.bounds.minX - lastBounds.maxX) < 0.5 { // 隣接するブロックかどうかの閾値
                        currentLine += " " + block.text
                    } else {
                        lines.append(currentLine)
                        currentLine = block.text
                    }
                    lastBounds = block.bounds
                }
                lines.append(currentLine) // 最後の行を追加
                print(lines)
                completion(lines) // 完了時にクロージャを呼び出す
            }
        }

        textRecognitionRequest.recognitionLevel = .accurate

        textRecognitionRequest.usesLanguageCorrection = true
        textRecognitionRequest.recognitionLanguages = ["ja-JP", "en-US"]

        do {
            try requestHandler.perform([textRecognitionRequest])
        } catch {
            print("Error performing text recognition: \(error.localizedDescription)")
        }
    }
}
