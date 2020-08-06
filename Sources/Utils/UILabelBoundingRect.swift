import UIKit

extension UILabel {
    
    public enum Attribute: Hashable {
        static let automaticCalculateShadows: CGSize = .init(width: -9999, height: -9999)
        
        case font(UIFont)
        case numberOfLines(Int)
        case lineBreakMode(NSLineBreakMode)
        case textAlignment(NSTextAlignment)
        case minimumScaleFactor(CGFloat)
        case shadowOffset(CGSize)
        
        public func hash(into hasher: inout Hasher) {
            switch self {
            case .font:                        hasher.combine("font")
            case .numberOfLines:               hasher.combine("numberOfLines")
            case .lineBreakMode:               hasher.combine("lineBreakMode")
            case .textAlignment:               hasher.combine("textAlignment")
            case .minimumScaleFactor:          hasher.combine("minimumScaleFactor")
            case .shadowOffset:                hasher.combine("shadowOffset")
            }
        }
        
        struct Context {
            var font: UIFont = .systemFont(ofSize: 17)
            var numberOfLines: Int = 0
            var lineBreakMode: NSLineBreakMode = .byTruncatingTail
            var textAlignment: NSTextAlignment = .left
            var minimumScaleFactor: CGFloat = 0
            var shadowOffset: CGSize = Attribute.automaticCalculateShadows
            
            fileprivate var firstLineHeadIndent: CGFloat = 0
        }
    }
}

private extension Array where Element == UILabel.Attribute {
    
    func context() -> UILabel.Attribute.Context {
        return Set(self).reduce(into: UILabel.Attribute.Context()) {
            switch $1 {
            case let .font(value):                  return $0.font = value
            case let .numberOfLines(value):         return $0.numberOfLines = value
            case let .lineBreakMode(value):         return $0.lineBreakMode = value
            case let .textAlignment(value):         return $0.textAlignment = value
            case let .minimumScaleFactor(value):    return $0.minimumScaleFactor = value
            case let .shadowOffset(value):          return $0.shadowOffset = value
            }
        }
    }
}

extension UILabel {
    
    public static func boundingRect(with string: String, size: CGSize, attributes: Attribute...) -> CGSize {
        guard !string.isEmpty else { return .zero }
        let context = attributes.context()
        let attributedString = NSAttributedString(string, context.font, context.lineBreakMode, context.textAlignment)
        return boundingRect(with: attributedString, size: size, context: context)
    }
    
    public static func boundingRect(with attributedString: NSAttributedString, size: CGSize, attributes: Attribute...) -> CGSize {
        guard !attributedString.string.isEmpty else { return .zero }
        var context = attributes.context()
        //对于属性字符串总是加上默认的字体和段落信息。
        let text = NSMutableAttributedString(
            attributedString.string,
            context.font,
            context.lineBreakMode,
            context.textAlignment
        )
        
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length), options: .init(rawValue: 0)) { (attrs, range, _) in
            text.addAttributes(attrs, range: range)
        }
        
        //这里再次取段落信息，因为有可能属性字符串中就已经包含了段落信息。
        if #available(iOS 11.0, *) {
            if let _style = text.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle {
                context.firstLineHeadIndent = _style.firstLineHeadIndent
            }
            
            if context.shadowOffset == Attribute.automaticCalculateShadows{
                if let shadow = text.attribute(.shadow, at: 0, effectiveRange: nil) as? NSShadow {
                    context.shadowOffset = shadow.shadowOffset
                } else {
                    context.shadowOffset = .zero
                }
            }
        }
        return boundingRect(with: text, size: size, context: context)
    }
}

extension UILabel {
    
    fileprivate static func boundingRect(with attributedString: NSAttributedString, size: CGSize, context: Attribute.Context) -> CGSize {
        //构造出一个NSStringDrawContext
        //因为下面几个属性都是未公开的属性，所以我们用KVC的方式来实现。
        let drawingContext = NSStringDrawingContext()
        drawingContext.minimumScaleFactor = context.minimumScaleFactor
        drawingContext.setValue(context.numberOfLines, forKey: "maximumNumberOfLines")
        drawingContext.setValue(true, forKey: "wantsNumberOfLineFragments")
        
        if context.numberOfLines != 1 { drawingContext.setValue(true, forKey: "wrapsForTruncationMode") }
        
        //调整fitsSize的值, 这里的宽度调整为只要宽度小于等于0或者显示一行都不限制宽度，而高度则总是改为不限制高度。
        var fitsSize = CGSize(width: size.width, height: .greatestFiniteMagnitude)
        if fitsSize.width <= 0 || context.numberOfLines == 1 {
            fitsSize.width = .greatestFiniteMagnitude
        }
        //计算属性字符串的bounds值。
        var rect = attributedString.boundingRect(with: fitsSize, options: .usesLineFragmentOrigin, context: drawingContext)
        
        //需要对段落的首行缩进进行特殊处理！
        //如果只有一行则直接添加首行缩进的值，否则进行特殊处理。。
        if #available(iOS 11.0, *),
            context.firstLineHeadIndent != 0.0,
            let drawingLines = drawingContext.value(forKey: "numberOfLineFragments") as? Int {
            //得到绘制出来的行数
            switch drawingLines {
            case 1:
                rect.size.width += context.firstLineHeadIndent
            default:
                //取内容的行数。
                let lines = attributedString.string.components(separatedBy: .newlines)
                //有效的内容行数要减去最后一行为空行的情况。
                let contentLines = lines.count - (lines.last?.count == 0 ? 1 : 0)
                let numberOfLines = min(context.numberOfLines == 0 ? .max : context.numberOfLines, contentLines)
                //只有绘制的行数和指定的行数相等时才添加上首行缩进！这段代码根据反汇编来实现，但是不理解为什么相等才设置？
                if drawingLines == numberOfLines {
                    rect.size.width += context.firstLineHeadIndent
                }
            }
        }
        //加上阴影的偏移
        if context.shadowOffset != .zero {
            rect.size.width += abs(context.shadowOffset.width)
            rect.size.height += abs(context.shadowOffset.height)
        }
        //取fitsSize和rect中的最小宽度值。
        rect.size.width =  min(fitsSize.width, rect.size.width)
        
        //转化为可以有效显示的逻辑点, 这里将原始逻辑点乘以缩放比例得到物理像素点，然后再取整，然后再除以缩放比例得到可以有效显示的逻辑点。
        let scale = UIScreen.main.scale
        rect.size.width = (rect.size.width * scale).rounded(.up) / scale
        rect.size.height = (rect.size.height * scale).rounded(.up) / scale
        return rect.size
    }
}

extension NSAttributedString {
    
    fileprivate convenience init(_ string: String, _ font: UIFont, _ lineBreakMode: NSLineBreakMode, _ textAlignment: NSTextAlignment) {
        let style = NSMutableParagraphStyle()
        style.alignment = textAlignment
        style.lineBreakMode = lineBreakMode
        
        //系统大于等于11才设置行断字策略。
        if #available(iOS 11.0, *) { style.setValue(1, forKey: "lineBreakStrategy") }
        
        //对于属性字符串总是加上默认的字体和段落信息。
        self.init(string: string, attributes: [.font: font, .paragraphStyle: style])
    }
}
