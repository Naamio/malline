#if !os(Linux)
    import Foundation
    
    class NowTag : TagType {
        
        // MARK: - Class Functions
        
        class func parse(_ parser:TokenParser, token:Token) throws -> TagType {
            var format:Variable?
            
            let components = token.components()
            guard components.count <= 2 else {
                throw StencilSyntaxError("'now' tags may only have one argument: the format string `\(token.contents)`.")
            }
            if components.count == 2 {
                format = Variable(components[1])
            }
            
            return NowTag(format:format)
        }
        
        // MARK: - Instance Functions
        
        let format:Variable
        
        init(format:Variable?) {
            self.format = format ?? Variable("\"yyyy-MM-dd 'at' HH:mm\"")
        }
        
        func render(_ context: Context) throws -> String {
            let date = Date()
            let format = try self.format.resolve(context)
            var formatter:DateFormatter?
            
            if let format = format as? DateFormatter {
                formatter = format
            } else if let format = format as? String {
                formatter = DateFormatter()
                formatter!.dateFormat = format
            } else {
                return ""
            }
            
            return formatter!.string(from: date)
        }
    }
#endif
