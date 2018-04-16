import XCTest
@testable import Accountant

private struct AnySupervisor: Supervisor {
    
    var handle: () -> Never
    
    func trap(_ message: @autoclosure () -> String, file: StaticString, line: UInt) -> Never {
        handle()
    }
    
}

private extension Thread {
    
    enum TerminationRoute {
        case normal
        case earlyExit
    }
    
    static func supervise(_ work: @escaping () -> Void) -> TerminationRoute {
        let oldSupervisor = AppSupervisor
        defer {
            AppSupervisor = oldSupervisor
        }
        
        var termination = TerminationRoute.normal
        let sema = DispatchSemaphore(value: 0)
        let thread = Thread {
            AppSupervisor = AnySupervisor {
                termination = .earlyExit
                sema.signal()
                Thread.exit()
                fatalError("Unreachable")
            }
            work()
            sema.signal()
        }
        thread.start()
        sema.wait()
        return termination
    }
    
}

func XCTAssertFatalError(_ message: String = "Expected fatal error", file: StaticString = #file, line: UInt = #line, _ work: @escaping () -> Void) {
    let termination = Thread.supervise(work)
    
    if termination != .earlyExit {
        XCTFail(message, file: file, line: line)
    }
}
