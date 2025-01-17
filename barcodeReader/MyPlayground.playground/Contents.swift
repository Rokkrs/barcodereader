import Foundation

func test() {

}

let queue = DispatchQueue(label: "com.example.queue")

queue.async {
    // Execute first
    print("Hello World!")
}

queue.async {
    // Execute second
    print("Hello2 World!")
}

let globalQueue = DispatchQueue.global().async {
    // download images
    
    
    DispatchQueue.main.async {
        // refresh ui
    }
}

let concurrentQueue = DispatchQueue(label: "my.concurrent.queue", attributes: .concurrent)
concurrentQueue.async {
 print("Concurrent Task 1")
}
concurrentQueue.async {
 print("Concurrent Task 2")
}


//Task {
//    print(Thread.current)
//}

Task(priority: .low) {
 print("Low priority task")
}
Task(priority: .high) {
 print("High priority task")
}

test()
 
//how to call a DispatchQueue

