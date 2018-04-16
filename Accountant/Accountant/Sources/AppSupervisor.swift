import Foundation

protocol Supervisor {
    
    func trap(_ message: @autoclosure () -> String, file: StaticString, line: UInt) -> Never
    
}

private struct TerminalSupervisor: Supervisor {
    
    func trap(_ message: @autoclosure () -> String, file: StaticString, line: UInt) -> Never {
        Swift.fatalError(message, file: file, line: line)
    }
}

var AppSupervisor: Supervisor = TerminalSupervisor()

extension Supervisor {
    
    func precondition(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        if !condition() {
            trap(message, file: file, line: line)
        }
    }
    
    func preconditionFailure(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
        trap(message, file: file, line: line)
    }
    
    func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
        trap(message, file: file, line: line)
    }
    
}
