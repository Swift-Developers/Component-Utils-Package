import XCTest
@testable import Utils

final class UILabelBoundingRectTest: XCTestCase {
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    func testShadowOffset() {
        let fitSize = CGSize(width: 0, height: 100)
        let label = UILabel.random(of: String.random(ofLength: 10))
        label.numberOfLines = 1
        let sz1  = label.sizeThatFits(fitSize)
        let sz2 = UILabel.boundingRect(
            with: label.text!,
            size: fitSize,
            attributes:
            .font(label.font),
            .numberOfLines(label.numberOfLines),
            .textAlignment(label.textAlignment),
            .minimumScaleFactor(label.minimumScaleFactor)
        )
        XCTAssertEqual(sz1, sz2)
    }
    
    func testSimpleText() {
        let timer1 = PerformanceTimer("简单文本计算UILabel")
        let timer2 = PerformanceTimer("简单文本计算非UILabel")
        
        for _ in 0 ..< 5000  {
            let text = String.random(ofLength: Int.random(in: 1 ... 100))
            let fitSize =  CGSize(width: .random(in: 0 ... 1000),
                                  height: .random(in: 0 ... 1000))
            let label = UILabel.random(of: text)
            
            let sz1  = timer1 { label.sizeThatFits(fitSize) }
            
            let sz2 = timer2 {
                UILabel.boundingRect(
                    with: text,
                    size: fitSize,
                    attributes:
                    .font(label.font),
                    .numberOfLines(label.numberOfLines),
                    .lineBreakMode(label.lineBreakMode),
                    .textAlignment(label.textAlignment),
                    .minimumScaleFactor(label.minimumScaleFactor),
                    .shadowOffset(.zero)
                )
            }
            XCTAssertEqual(sz1, sz2)
        }
        print(timer1)
        print(timer2)
    }
    
    /// 测试富文本
    func testAttributedText() {
        let timer1 = PerformanceTimer("富文本计算UILabel")
        let timer2 = PerformanceTimer("富文本计算非UILabel")
        
        for _ in 0 ..< 5000  {
            let text = String.random(ofLength: Int.random(in: 1 ... 100))
            let fitSize =  CGSize(width: .random(in: 0 ... 1000),
                                  height: .random(in: 0 ... 1000))
            
            let attributedText = NSMutableAttributedString(string: text)
            let range1 = NSRange(location: 0, length:  Int.random(in: 0 ... attributedText.length))
            let style1 = NSMutableParagraphStyle.random
            let font1: UIFont = .random
            
            let range2 = NSRange(location: range1.length, length: attributedText.length - range1.length)
            let style2 = NSMutableParagraphStyle.random
            let font2: UIFont = .random
            
            attributedText.addAttribute(.paragraphStyle, value: style1, range: range1)
            attributedText.addAttribute(.font, value: font1, range: range1)
            attributedText.addAttribute(.paragraphStyle, value: style2, range: range2)
            attributedText.addAttribute(.font, value: font2, range: range2)
            
            let label = UILabel.random()
            label.attributedText = attributedText
            
            let sz1 = timer1 { label.sizeThatFits(fitSize) }
            let sz2 = timer2 {
                UILabel.boundingRect(
                    with: attributedText,
                    size: fitSize,
                    attributes:
                    .font(label.font),
                    .numberOfLines(label.numberOfLines),
                    .lineBreakMode(label.lineBreakMode),
                    .textAlignment(label.textAlignment),
                    .minimumScaleFactor(label.minimumScaleFactor),
                    .shadowOffset(.zero)
                )
            }
            XCTAssertEqual(sz1, sz2)
        }
        print(timer1)
        print(timer2)
    }
    
    static var allTests = [
        ("testExample", testExample),
        ("testShadowOffset", testShadowOffset),
        ("testSimpleText", testSimpleText),
        ("testAttributedText", testAttributedText)
    ]
}

fileprivate extension String {
    
    static func random(ofLength length: Int) -> String {
        guard length > 0 else { return "" }
        let base = ["您","好","中","国","w","i","d","t","h",",","。","a","b","c","\n", "1","5","2","j","A","J","0","🆚","👃"," "]
        var randomString = ""
        for _ in 1...length {
            randomString.append(base.randomElement()!)
        }
        return randomString
    }
}

fileprivate extension UILabel {
    
    static func random(of text: String? = nil) -> UILabel {
        let label = UILabel()
        text.map { label.text = $0 }
        label.numberOfLines = .random(in: 0 ... 100)
        label.textAlignment = .random
        label.lineBreakMode = .random
        label.font = .random
        return label
    }
}

fileprivate extension NSTextAlignment {
    
    static var random: NSTextAlignment {
        NSTextAlignment(rawValue: Int.random(in: 0 ... 4))!
    }
}

fileprivate extension NSLineBreakMode {
    
    static var random: NSLineBreakMode {
        NSLineBreakMode(rawValue: Int.random(in: 0 ... 5))!
    }
}

fileprivate extension UIFont {
    
    /// 随机所有字体会有性能影响
//    fileprivate static let names = UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }
    
    static var random: UIFont {
        UIFont.systemFont(ofSize: .random(in: 0 ... 35), weight: Weight(.random(in: 0 ... 10)))
    }
}

fileprivate extension NSMutableParagraphStyle {
    
    static var random: NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = .random(in: 0 ... 20)
        style.firstLineHeadIndent = .random(in: 0 ... 10)
        style.paragraphSpacing = .random(in: 0 ... 30)
        style.headIndent = .random(in: 0 ... 10)
        style.tailIndent = .random(in: 0 ... 10)
        return style
    }
}

fileprivate extension UIEdgeInsets {
    
    static var random: UIEdgeInsets {
        .init(top: .random(in: 0...50),
              left: .random(in: 0...50),
              bottom: .random(in: 0...50),
              right: .random(in: 0...50)
        )
    }
}
