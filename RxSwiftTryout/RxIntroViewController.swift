//
//  RxIntroViewController.swift
//  RxSwiftTryout
//
//  Created by Benjamin Stone on 6/14/18.
//  Copyright © 2018 ShopKeep. All rights reserved.
//

import UIKit
import RxSwift

class RxIntroViewController: UIViewController {
    let helloRx: Observable<String> = Observable.just("Hello RxSwift")
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let disposeBag = DisposeBag()
        let mySubject = ReplaySubject<String>.create(bufferSize: 3)
        mySubject.onNext("Initial Message 1")
        mySubject.asObservable()
            .subscribe(onNext: {(str: String) in
                print("The new string is \(str)")
            })
            .disposed(by: disposeBag)
        mySubject.onNext("Hello")
        mySubject.onNext("World!")

        helloRx
            .subscribe(onNext: {(str) in
                print(str)
            })
        .disposed(by: disposeBag)
    }
}
