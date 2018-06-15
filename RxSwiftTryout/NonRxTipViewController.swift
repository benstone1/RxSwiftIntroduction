//
//  NonRxTipViewController.swift
//  RxSwiftTryout
//
//  Created by Benjamin Stone on 6/14/18.
//  Copyright © 2018 ShopKeep. All rights reserved.
//

import UIKit

protocol NonRxTipViewModelDelegate {
    func didChangeTipAmountText(to newValue: String)
    func didChangedTipPercentageText(to newValue: String)
}

class NonRxTipViewController: UIViewController, NonRxTipViewModelDelegate {
    static let startingPrice: Double = 20
    let viewModel: ViewModel = {
        return ViewModel(priceBeforeTip: startingPrice)
    }()

    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var tipPercentageLabel: UILabel!

    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        viewModel.updateTipAmount(to: sender.value)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
    }
    func didChangeTipAmountText(to newValue: String) {
        tipAmountLabel.text = newValue
    }
    func didChangedTipPercentageText(to newValue: String) {
        tipPercentageLabel.text = newValue
    }
}

extension NonRxTipViewController {
    class ViewModel {
        var delegate: NonRxTipViewModelDelegate?
        init(priceBeforeTip: Double) {
            self.priceBeforeTip = priceBeforeTip
        }
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
        private var formattedTipAmountString: String {
            return String(format: "Tip Amount: $%.02f", tipAmount)
        }
        private var formattedTipPercentageString: String {
            let tipPercent = tipAmount / priceBeforeTip * 100
            return String(format: "%.02f", tipPercent) + " %"
        }

        private func updateTipAmountText() {
            delegate?.didChangeTipAmountText(to: formattedTipAmountString)
        }
        private func updateTipPercentageText() {
            delegate?.didChangedTipPercentageText(to: formattedTipPercentageString)
        }
    }
}
