//
//  Bank.swift
//  BankManagerConsoleApp
//
//  Created by Siwon Kim on 2021/12/23.
//

import Foundation

protocol BankDelegate: AnyObject {
    func printClosingMessage(customers: Int, processingTime: Double)
}

class Bank {
    private let customerQueue: Queue<Customer> = Queue<Customer>()
    private var bankClerk: BankClerk
    private weak var delegate: BankDelegate?
    private let randomCount = Int.random(in: 10...30)

    init(bankClerk: BankClerk, delegatee: BankDelegate) {
        self.bankClerk = bankClerk
        self.delegate = delegatee
        setupCustomerQueue(with: randomCount)
    }
    
    func setupCustomerQueue(with amount: Int) {
        (1...amount).forEach { _ in
            guard let lastCustomer = customerQueue.returnAllElements().last else {
                customerQueue.enqueue(value: Customer(turn: 1))
                return
            }
            customerQueue.enqueue(value: Customer(turn: lastCustomer.turn + 1))
        }
    }
    
    func resetCustomerQueue() {
        customerQueue.clear()
    }
    
    func returnAllCustomers() -> [Customer] {
        return customerQueue.returnAllElements()
    }
    
    @objc func open() {
        let semaphore = DispatchSemaphore(value: 2)
        let depositQueue = DispatchQueue(label: "deposit", attributes: .concurrent)
        let loanQueue = DispatchQueue(label: "loan")
        let bankGroup = DispatchGroup()
        
        var processedCustomers = 0
        let startTime = DispatchTime.now()
        
        while let customer = customerQueue.dequeue() {
            switch customer.task {
            case .deposit:
                depositQueue.async(group: bankGroup) {
                    semaphore.wait()
                    self.bankClerk.work(with: customer)
                    semaphore.signal()
                }
            case .loan:
                loanQueue.async(group: bankGroup) {
                    self.bankClerk.work(with: customer)
                }
            }
            processedCustomers += 1
        }
        
        bankGroup.wait()
        
        let endTime = DispatchTime.now()
        
        let totalProcessingTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
        close(totalCustomers: processedCustomers, totalProcessingTime: totalProcessingTime)
    }
    
    func close(totalCustomers: Int, totalProcessingTime: Double) {
        delegate?.printClosingMessage(customers: totalCustomers, processingTime: totalProcessingTime)
    }
}