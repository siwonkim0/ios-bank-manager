//
//  Banker.swift
//  BankManagerConsoleApp
//
//  Created by Wonhee on 2021/01/04.
//

import Foundation

class Banker {
    private let number: Int
    private let workingQueue: DispatchQueue
    private let startTaskMessgae = "%d번 %@고객 %@업무 시작"
    private let endTaskMessgae = "%d번 %@고객 %@업무 완료"
    
    // MARK: - init func
    init(_ number: Int) {
        self.workingQueue = DispatchQueue(label: "\(number)")
        self.number = number
        setNotification()
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(processingLoanTask(_:)), name: .finishLoanJudge, object: nil)
    }
    
    @objc func processingLoanTask(_ notification: Notification) {
        
    }
    
    func startWork(customer: Customer, group: DispatchGroup) {
        group.enter()
        print(String(format: startTaskMessgae, customer.waitingNumber, customer.grade.description, customer.taskType.description))
        switch customer.taskType {
        case .loan:
            processLoan(customer: customer, group: group)
        case .deposit:
            processDeposit(customer: customer, group: group)
        }
    }
    
    private func processLoan(customer: Customer, group: DispatchGroup) {
        BankHeadOffice.shared.addJudge(bankerNumber: self.number, customer: customer, group: group)
    }
    
    private func processDeposit(customer: Customer, group: DispatchGroup) {
        workingQueue.asyncAfter(deadline: .now() + customer.taskType.time) {
            self.finishWork(customer: customer, group: group)
        }
    }
    
    private func finishWork(customer: Customer, group: DispatchGroup) {
        print(String(format: endTaskMessgae, customer.waitingNumber, customer.grade.description, customer.taskType.description))
        NotificationCenter.default.post(name: .finishBankerTask, object: self.number)
        group.leave()
    }
}
