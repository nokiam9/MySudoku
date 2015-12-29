//
//  SudokuBase.swift
//  MySudoku
//
//  Created by imac on 15/12/29.
//  Copyright © 2015年 caogo.cn. All rights reserved.
//

import Foundation

// 定义所有的变量状态
enum SudokuCellStatus {
    case initialized                    // Cell的数字从题目中读出，不可修改value
    case submitted                      // 用户已经推算出Cell的Value
    case unsubmitted                    // value的数值未知
}

// 定义所有的基本Class
class  SudokuCell: NSObject {
    var position: Int
    var status: SudokuCellStatus
    var value: Int                  ////填充Subject中的正确答案
    var candidateList: Set<Int>
    
    var row: Int {get {return Int(position / 9) }}
    var col: Int {get {return Int(position % 9) }}
    var block: Int {get {return (position / 27 * 3 + position % 27 / 3 % 3 ) }}
    
    //初始化时填写了正确答案value，根据visiable分别设置status，此时candidateList为空
    init(position: Int, value: Int, visiable: Bool) {
        self.position = position
        self.status = visiable ? SudokuCellStatus.initialized : SudokuCellStatus.unsubmitted
        self.value = value
        self.candidateList = []
    }
    
    //带候选列表的初始化时，准备用于游戏过程状态的恢复
    init(position: Int, candidateList: Set<Int>) {
        self.position = position
        self.status = SudokuCellStatus.unsubmitted
        self.candidateList = candidateList
        self.value = 0
    }
    
    func isRightValue(submitValue: Int) ->Bool {
        return submitValue == value
    }
    
    // 向SudokuCell提交value，注意使用commitValue之前应该在Matrix中检查合法性，但目前只是简单判断提交的数字是否为正确答案
    func commitValue(submitValue: Int) ->Bool {
        if submitValue == value  && status == SudokuCellStatus.unsubmitted {
            self.status = SudokuCellStatus.submitted
            return true
        }
        else {
            return false
        }
    }
    
    func insertCandidate(insertValue: Int) -> Bool {
        if candidateList.contains(insertValue) {
            return false
        }
        else {
            candidateList.insert(insertValue)
            return true
        }
    }
    
    func removeCandidate(removeValue: Int) -> Bool {
        if candidateList.contains(removeValue) {
            candidateList.remove(removeValue)
            return true
        }
        else {
            return false
        }
    }
}

