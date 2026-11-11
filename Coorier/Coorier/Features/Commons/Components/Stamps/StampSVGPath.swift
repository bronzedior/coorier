//
//  StampSVGPath.swift
//  Coorier
//

import SwiftUI

enum StampSVGPath {
    static func path(from strings: [String], origin: CGPoint) -> Path {
        var path = Path()
        for string in strings {
            path.addPath(parse(string, shift: origin))
        }
        return path
    }

    private static func parse(_ string: String, shift: CGPoint) -> Path {
        var path = Path()
        let tokens = tokenize(string)
        var index = 0
        var command: Character = "M"
        var current = CGPoint.zero

        func next() -> CGFloat {
            defer { index += 1 }
            return CGFloat(Double(tokens[index].number ?? 0))
        }

        func point(_ posX: CGFloat, _ posY: CGFloat) -> CGPoint {
            CGPoint(x: posX - shift.x, y: posY - shift.y)
        }

        while index < tokens.count {
            if let letter = tokens[index].letter {
                command = letter
                index += 1
                if command == "Z" {
                    path.closeSubpath()
                    continue
                }
            }
            switch command {
            case "M":
                current = CGPoint(x: next(), y: next())
                path.move(to: point(current.x, current.y))
                command = "L"
            case "L":
                current = CGPoint(x: next(), y: next())
                path.addLine(to: point(current.x, current.y))
            case "H":
                current.x = next()
                path.addLine(to: point(current.x, current.y))
            case "V":
                current.y = next()
                path.addLine(to: point(current.x, current.y))
            case "C":
                let first = CGPoint(x: next(), y: next())
                let second = CGPoint(x: next(), y: next())
                current = CGPoint(x: next(), y: next())
                path.addCurve(
                    to: point(current.x, current.y),
                    control1: point(first.x, first.y),
                    control2: point(second.x, second.y)
                )
            default:
                index += 1
            }
        }
        return path
    }

    private struct Token {
        var letter: Character?
        var number: Double?
    }

    private static func tokenize(_ string: String) -> [Token] {
        var tokens: [Token] = []
        var buffer = ""

        func flush() {
            if !buffer.isEmpty {
                tokens.append(Token(number: Double(buffer)))
                buffer = ""
            }
        }

        for character in string {
            if character.isLetter && character != "e" {
                flush()
                tokens.append(Token(letter: character))
            } else if character == " " || character == "\n" || character == "," {
                flush()
            } else if character == "-" {
                if !buffer.isEmpty && !buffer.hasSuffix("e") {
                    flush()
                }
                buffer.append(character)
            } else {
                buffer.append(character)
            }
        }
        flush()
        return tokens
    }
}
