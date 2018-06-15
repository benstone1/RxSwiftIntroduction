
# RXSwift Introduction

## Objectives

1. Understand why RXSwift is used
2. Create Observables
3. Create PublishSubjects, Variables and BehaviorSubjects
4. Build a small app using RXSwift 

## Resources

1. [RxSwift Documentation](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md)
2. [Krzysztof Siejkowski](https://academy.realm.io/posts/krzysztof-siejkowski-mobilization-2017-rxswift-deep-cuts/)
3. [raywenderlich](https://www.raywenderlich.com/126522/reactivecocoa-vs-rxswift)
4. [swiftpearls](http://swiftpearls.com/RxSwift-for-dummies-1-Observables.html)

# 1. Why RXSwift?

### What is RXSwift?

Reactive Swift is a programming methodology that aims to make complex asynchronous code easier to test, read and write.  Reactive Swift differentiates itself from Object (or Protocol) Oriented Swift by reconceptualizing how information moves between objects.  RXSwift is often used together with [MVVM archicture](https://medium.com/flawless-app-stories/how-to-use-a-model-view-viewmodel-architecture-for-ios-46963c67be1b).

### Testing

Using RXSwift and MVVM allows us to separate the ViewController from the ViewModel.  We connect the views in the ViewController to the ViewModel and tell them to watch for changes and update accordingly.  Because our ViewModel is the source of truth about what the ViewController should display, we can test the ViewModel in isolation to confirm that its behavior matches what we expect.

### Clear communication

Without RXSwift, there are several competing ways to communicate between classes.  Delegation, KVO, callbacks, and Notifications are all separate systems that must be tracked and have their own challenges.  

For example, delegation is not very flexible because a class can only have one delegate.  If you want to inform multiple objects that a change has happened, you have to manually set each of those objects.  Additionally, if you want to be informed about more events, the protocol must be updated.  This creates a lot of overhead.

RXSwift allows for any number of observers to subscribe to events in something that is observable.

# 2. Observables and Events

### Observables

Observables are at the heart of how RXSwift works.  An `Observable` is anything that you want to observe.  Creating an Observable in RxSwift is simple:

```swift
let myObservableInt = Observable.just(5)
```

Creating an Observable doesn't do anything by itself.  In order for anything interesting to happen, we need someone to *subscribe* to the observable and execute code when something happens.

```swift
let mySubscription = Observable.just(5).subscribe{(event) in
    switch event {
    case .completed:
        print("completed")
    case .next(let element):
        print("The next number is \(element)")
    case .error(let error):
        print("An error occurred: \(error)")
    }
}
```
```bash
console
~~~~~~~~~~
The next number is 5
completed
```

The subscribe(on:_) method takes in a closure that takes an Event<Int> as input, and returns Void.  An Event is a simple enum that has three cases:


[RxSwift docs](https://github.com/ReactiveX/RxSwift/blob/master/RxSwift/Event.swift)

```swift
public enum Event<Element> {
    /// Next element is produced.
    case next(Element)

    /// Sequence terminated with an error.
    case error(Swift.Error)

    /// Sequence completed successfully.
    case completed
}
```

In our case of a simple integer, we observe two events: a next event with the next (in this case only) element, then a complemention event.  

Observables can also be made from sequences.  Below, we create an observable from an array of Ints, then print out each value.

```swift
let mySubscription = Observable.from(["1","2","3","4","5"]).subscribe{(event) in
    switch event {
    case .completed:
        print("completed")
    case .next(let element):
        print("The next number is \(element)")
    case .error(let error):
        print("An error occurred: \(error)")
    }
}
```

```bash
console
~~~~~~~~~~
The next number is 1
The next number is 2
The next number is 3
The next number is 4
The next number is 5
completed
```

### Memory Management

Creating a subscription is a process that can easily create retain cycles.  It's important to use `weak self` if you are capturing any variables from your environment.  Additionally, you need to ensure that the subscriptions dissappear after you don't need them.  Similar to NSNotificationCenter's removeObserver method, we need to dispose of our subscriptions.  This is done through a `DisposeBag` that returns ARC-style memory management.

```swift
Observable.from(["1","2","3","4","5"]).subscribe{(event) in
    switch event {
    case .completed:
        print("completed")
    case .next(let element):
        print("The next number is \(element)")
    case .error(let error):
        print("An error occurred: \(error)")
    }
}.disposed(by: DisposeBag())
```


### Threading

One of the advantages of RxSwift is that it gives you control over the threads that the closures will run on.  RxSwift is good at handling asynchronous code because it allows you to be explicit about threads.  Different subscriptions can be scheduled to run on different queues.


```swift
Observable.from(["1","2","3","4","5"])
    .observeOn(MainScheduler.instance)
    .subscribe{(event) in
    switch event {
    case .completed:
        print("completed")
    case .next(let element):
        print("The next number is \(element)")
    case .error(let error):
        print("An error occurred: \(error)")
    }
}
    .disposed(by: DisposeBag())
```


# 3 . PublishSubjects, BehaviorSubjects and Variables

Observables provide a clear way to pass information to anyone who is interested.  If you have a reference to an observable, any number of objects can subscribe to it and do whatever they want with the events they get.

In a traditional imperative codebase, we don't just receive information.  Users of an application input commands which cause classes to update their properties and display an updated UI.  For example, imagine a simple screen with a stepper and a label displaying the stepper's current value.  Incrementing the stepper updates a property that then updates the UI.  How can we use RxSwift to model giving inputs instead of just receiving them?

RxSwift has four Subject classes that are Observables, and have a method you `onNext` which you can input new values to.

The four classes are:

- PublishSubject
- BehaviorSubject
- Variable (which is really just a wrapper on a BehaviorSubject)
- ReplaySubject

### PublishSubject

We can use a PublishSubject to control our own inputs

```swift
let disposeBag = DisposeBag()
let mySubject = PublishSubject<String>()
mySubject.asObservable()
    .subscribe(onNext: {(str: String) in
        print("The new string is \(str)")
    })
    .disposed(by: disposeBag)
mySubject.onNext("Hello")
mySubject.onNext("World!")
```

```
console
~~~~~~~~~~
The new string is Hello
The new string is World!
```
Unless we call `mySubject.onCompleted()` ourselves, the sequence will not complete.

So why are there four different Subject types?  They have slightly different behavior about how to handle events that have already occurred.  When subscribing to a PublishSubject, you will ignore any events that happened before subscribing.

```swift
let disposeBag = DisposeBag()
let mySubject = PublishSubject<String>()
mySubject.onNext("Initial Message:")
mySubject.asObservable()
    .subscribe(onNext: {(str: String) in
        print("The new string is \(str)")
    })
    .disposed(by: disposeBag)
mySubject.onNext("Hello")
mySubject.onNext("World!")
```

```bash
console
~~~~~~~~~~
The new string is Hello
The new string is World!
```

### BehaviorSubject

When subscribing to a BehaviorSubject, however, you will immediately receive its most recent event.  Because of this, BehaviorSubject's must be created with an initial state to give to observers.

```swift
let disposeBag = DisposeBag()
let mySubject = BehaviorSubject(value: "Initial Message: ")
mySubject.asObservable()
    .subscribe(onNext: {(str: String) in
        print("The new string is \(str)")
    })
    .disposed(by: disposeBag)
mySubject.onNext("Hello")
mySubject.onNext("World!")
```

```bash
console
~~~~~~~~~~
The new string is Initial Message: 
The new string is Hello
The new string is World!
```

### Variable

A Variable is just a wrapper around a BehaviorSubject.  It's behavior is the same.

RxSwift Variable Initializer:

```swift
public init(_ value: Element) {
	 ```
    _value = value
    _subject = BehaviorSubject(value: value)
}
```

### ReplaySubject

A ReplaySubject is like a BehaviorSubject that can extend further back into the past.  When creating a ReplaySubject, you can specifiy the bufferSize which dictates how many previous events to repeat.

```swift
let disposeBag = DisposeBag()
let mySubject = ReplaySubject<String>.create(bufferSize: 3)
mySubject.onNext("Initial Message 1")
mySubject.onNext("Initial Message 2")
mySubject.onNext("Initial Message 3")
mySubject.onNext("Initial Message 4")
mySubject.asObservable()
    .subscribe(onNext: {(str: String) in
        print("The new string is \(str)")
    })
    .disposed(by: disposeBag)
mySubject.onNext("Hello")
mySubject.onNext("World!")
```

```bash
console
~~~~~~~~~~
The new string is Initial Message 2
The new string is Initial Message 3
The new string is Initial Message 4
The new string is Hello
The new string is World!
```

If there are fewer than `bufferSize` past events, it will replay all of them.