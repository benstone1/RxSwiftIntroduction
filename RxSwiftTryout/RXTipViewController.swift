//
//  ViewController.swift
//  RxSwiftTryout
//
//  Created by Gabe Heafitz on 6/13/18.
//  Copyright © 2018 ShopKeep. All rights reserved.
//

import UIKit
import RxSwift

class RXTipViewController: UIViewController {
    static let startingPrice: Double = 20
    let viewModel: ViewModel = {
        return ViewModel(priceBeforeTip: startingPrice)
    }()

    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var tipPercentageLabel: UILabel!
    private let disposeBag = DisposeBag()


    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        viewModel.updateTipAmount(to: sender.value)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindUIToViewModel()
    }

    func bindUIToViewModel() {
        viewModel.tipAmountText
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (newString: String) in
                self?.tipAmountLabel.text = newString
            })
            .disposed(by: disposeBag)
        viewModel.tipPercentageText
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (newString: String) in
                self?.tipPercentageLabel.text = newString
            })
            .disposed(by: disposeBag)
    }
}

extension RXTipViewController {
    class ViewModel {
        //Public API
        init(priceBeforeTip: Double) {
            self.priceBeforeTip = priceBeforeTip
        }
        var tipAmountText: Observable<String> { return tipAmountTextSubject.asObservable() }
        var tipPercentageText: Observable<String> { return tipPercentageTextSubject.asObservable() }

        func updateTipAmount(to newValue: Double) {
            tipAmount = newValue
        }

        //Private implementation
        private let priceBeforeTip: Double
        private(set) var tipAmount: Double = 0 {
            didSet {
                updateTipAmountText()
                updateTipPercentageText()
            }
        }

        lazy private var tipAmountTextSubject: BehaviorSubject<String> = {
            return BehaviorSubject<String>(value: tipAmount.stringFormatted())
        }()

        lazy private var tipPercentageTextSubject: BehaviorSubject<String> = {
            return BehaviorSubject<String>(value: tipAmount.percentageFormatted(of: priceBeforeTip))
        }()

        private func updateTipAmountText() {
            tipAmountTextSubject.onNext(tipAmount.stringFormatted())
        }
        private func updateTipPercentageText() {
            tipPercentageTextSubject.onNext(tipAmount.percentageFormatted(of: priceBeforeTip))
        }
    }
}
