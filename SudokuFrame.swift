//
//  SudokuFrame.swift
//  MySudoku
//
//  Created by imac on 15/12/29.
//  Copyright © 2015年 caogo.cn. All rights reserved.
//

import UIKit                            // 有大量控件原型在UIKit，不能import Foundation

// 定义所有的状态变量
enum SudokuGlobeMode {
    case submitting                     // 全局模式为提交状态
    case selecting                      // 此时用户可以记录可选数值
}

enum SudokuCellButtonType {
    case normal                         // Cell的默认状态，无边框&&无阴影
    case onFocus                        // 当前选中的焦点，committed时为绿色粗框，uncommitted是为红色粗框
    case withSameCommittedValue         // 状态为committed的Cell，而且value和焦点的Value相同：绿色粗框
    case withSameUncommittedValue       // 状态为uncommitted的Cell，而且候选数包含了焦点Value：绿色细框
    case inSameRowORSameCol             // 焦点为uncommitted的cell，与之相同row或col的cell将增加边框的阴影，暂不实现
}

enum SudokuItemButtonType {
    case waitingForSubmit               // GlobeMode为submmitting时，如果Cell的状态为unsubmitted，Item按钮状态为等待提交
    case selected                       // GlobeMode为selecting时，根据候选数值是否已被选择，Item的按钮状态在selected和avaiable中转换
    case available                      // 同上
    case disable                        // 如果Cell的状态为submitted或initialized，Item按钮状态为不可提交
}

// 所有frame需要的自定义控件class
class SudokuItemGroup {
    var itemGroup :[(button: SudokuItemButton, type: SudokuItemButtonType)] = []
    
    func createGroup(baseView: UIView) {
        for i in 1...9 {
            let item = SudokuItemButton(value: i)
            self.itemGroup.append((item,SudokuItemButtonType.waitingForSubmit))
            item.createButton(baseView)
        }
        showGroup(SudokuItemButtonType.waitingForSubmit)
    }
    
    func showGroup(type: SudokuItemButtonType) {
        for i in  0...8 {
            self.itemGroup[i].type = type
            itemGroup[i].button.showButton(itemGroup[i].type)
        }
    }
    
    func showGroup(candidate: Set<Int>) {
        for i in 0...8 {
            self.itemGroup[i].type = candidate.contains(i+1) ?  SudokuItemButtonType.selected : SudokuItemButtonType.available
            itemGroup[i].button.showButton(itemGroup[i].type)
        }
    }
}


/*
说明：update方法在修改状态之前，会主动刷新屏幕，恢复当前path列表中cellButton的status为normal
注意：update可能返回false，代表matrix即将失去focus，此时调用方不能再根据index刷新按钮状态
positon为－1，说明刚刚启动，还没有初始值
cellsWithSameCommittedValue加绿色粗款，触发条件：focus的status为submitted时起作用
cellsWithSameCandidatedValue加绿色细框，触发条件：同上
CellsWithSameRowOrCol加阴影效果，触发条件：focus的status为unsubmitted时起作用
*/
class SudokuCellMatrix {
    var matrix: [SudokuCellButton] = []
    var index: Int? = nil
    var path: [(position:Int, type: SudokuCellButtonType)] = []
    
    var setOfSameRow: Set<Int> {
        get {
            if index == nil { return [] }
            let col = index! / 9 ; return [9*col, 9*col+1, 9*col+2, 9*col+3, 9*col+4, 9*col+5, 9*col+6, 9*col+7, 9*col+8]
        }
    }
    
    var setOfSameCol: Set<Int> {
        get {
            if index == nil { return [] }
            let row = index! % 9
            return [row, row+9, row+18, row+27, row+36, row+45, row+54, row+63, row+72]
        }
    }
    
    var setOfSameBlock: Set<Int> {
        get {
            if index == nil { return [] }
            let block = index! / 27 * 3 + index! % 27 / 3 % 3
            let base = (block / 3) * 27 + (block % 3) * 3
            return [base, base+1, base+2, base+9, base+10, base+11, base+18, base+19, base+20]
        }
    }
    
    // 从subject中读取题目
    func loadSubject(baseView: UIView, subject: SudokuSubject) ->Bool {
        
        if subject.cells.count != 81 { return false }
        for i in 0...80 {
            let cell = SudokuCellButton(position: i, value: subject.cells[i].value, visiable: subject.cells[i].visible)
            self.matrix.append(cell)
            cell.createButton(baseView)
            cell.showButton()
        }
        return true
    }
    
    func updateIndex(newIndex: Int?) ->Bool {
        if  index != nil {
            for x in path {
                matrix[x.position].showButtonType(SudokuCellButtonType.normal)
            }
            self.path.removeAll()
        }
        
        if newIndex == nil {            // nil入参的效果就是丢失focus
            print("Warning: Matrix will lose focus porint.")
            self.index = nil
            return false
        }
        
        if index == newIndex {
            print("Warning: Duplicate click cell....")
            self.index = nil
            return false
        }
        
        self.index = newIndex
        
        switch matrix[newIndex!].status {
        case .initialized, .submitted:
            var list = setOfSameCommittedValue(matrix[newIndex!].value)
            for x in list {
                self.path.append((x, SudokuCellButtonType.withSameCommittedValue))
                matrix[x].showButtonType(SudokuCellButtonType.withSameCommittedValue)
            }
            
            list = setOfSameCandiateValue(matrix[newIndex!].value)
            for x in list {
                self.path.append((x, SudokuCellButtonType.withSameUncommittedValue))
                matrix[x].showButtonType(SudokuCellButtonType.withSameUncommittedValue)
            }
        case .unsubmitted :
            self.path.append((newIndex!, SudokuCellButtonType.onFocus))
            matrix[newIndex!].showButtonType(SudokuCellButtonType.onFocus)
        }
        return true
    }
    
    func setOfSameCommittedValue(value: Int) -> Set<Int> {
        var list: Set<Int> = []
        
        for x in matrix {
            if x.value == value && x.status != SudokuCellStatus.unsubmitted {
                list.insert(x.position)
            }
        }
        return list
    }
    
    func setOfSameCandiateValue(value: Int) -> Set<Int> {
        var list: Set<Int> = []
        
        for x in matrix {
            if x.candidateList.contains(value) && x.status == SudokuCellStatus.unsubmitted {
                list.insert(x.position)
            }
        }
        return list
    }
}

// 定义ModeSwtich按钮
class SudokuModeSwitch: NSObject {
    var button: UIButton = UIButton()
    var globeMode = SudokuGlobeMode.submitting     // 全局模式的默认值为提交模式
    
    func createButton(baseView: UIView) {
        button.frame = CGRectMake(245, 370, 60, 25)
        button.addTarget(self, action:"switchTapped:" , forControlEvents: UIControlEvents.TouchDown)
        baseView.addSubview(button)
        showButton()
    }
    
    func showButton() {
        
        switch globeMode {
        case   SudokuGlobeMode.submitting :
            button.titleLabel?.font = UIFont.systemFontOfSize(12)
            button.setTitle("提交模式", forState: .Normal)
            button.setTitleColor(UIColor.whiteColor(), forState:.Normal)
            button.backgroundColor=UIColor.redColor()
        case  SudokuGlobeMode.selecting :
            button.titleLabel?.font = UIFont.systemFontOfSize(12)
            button.setTitle("候选模式", forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState:.Normal)
            button.backgroundColor=UIColor.brownColor()
        }
    }
    
    /*
    注意：这里是使用addTarget方法的入口，class的初始化必须在主函数之中
    */
    func switchTapped(sender: UIButton) {
        mySwitchTapped(sender)
    }
}

// // 定义单个的Cell按钮，注意该Button是SudokuCell的子类
class SudokuCellButton: SudokuCell {
    var button: UIButton = UIButton()
    
    func createButton(baseView: UIView) {
        button.frame = CGRectMake(
            22+CGFloat(col * 31 + (block % 3 ) * 2),
            70+CGFloat(row * 31 + (block / 3) * 2),
            30, 30)
        /*
            注意：tag可以在addTarget中传递参数，这里用tag保存了这个button的position信息
        */
        button.tag = position
        /*
            注意：这是addTarget的标准方法，self是所在的View，action是需要调用的代理方法，forControlEvents是触发事件
            实际上，这相当于SDK集成环境中的@IBAction
        */
        button.addTarget(self, action: Selector("cellTapped:"), forControlEvents: UIControlEvents.TouchDown)
        
        baseView.addSubview(button)
        showButton()                                               // 注意，Cell按钮在create后直接调用了show
    }
    
    func showButton() {
        var title : String = ""
        
        switch status {                                                 // 根据cell.status显示titleLable
        case SudokuCellStatus.initialized, SudokuCellStatus.submitted :
            title = String(value)
            button.setTitle(String(value), forState: .Normal)           // TitleLabel显示已经提交的Value
            button.titleLabel!.font = UIFont.systemFontOfSize(16)
            button.setTitleColor(UIColor.whiteColor(), forState:.Normal)
            button.backgroundColor=UIColor.brownColor()
        case SudokuCellStatus.unsubmitted :
            for x in candidateList { title += String(x) }
            button.setTitle(title, forState: .Normal)                   // TitleLabel显示全部的候选数
            button.titleLabel!.font = UIFont.systemFontOfSize(9)
            button.titleLabel!.textAlignment = NSTextAlignment.Left
            button.titleLabel!.lineBreakMode = NSLineBreakMode.ByCharWrapping
            button.setTitleColor(UIColor.blackColor(), forState:.Normal)
            button.backgroundColor=UIColor.grayColor()
        }
    }
    
    func showButtonType(type: SudokuCellButtonType) {
        switch type {
        case SudokuCellButtonType.onFocus :
            button.layer.borderWidth = 2
            button.layer.borderColor = status == SudokuCellStatus.unsubmitted ?
                UIColor.greenColor().CGColor : UIColor.redColor().CGColor
        case SudokuCellButtonType.withSameCommittedValue :
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.greenColor().CGColor
        case SudokuCellButtonType.withSameUncommittedValue :
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.greenColor().CGColor
        case SudokuCellButtonType.inSameRowORSameCol :
            break                                               // 该方法尚未实现
        case SudokuCellButtonType.normal :
            button.layer.borderWidth = 0
            button.layer.borderColor = UIColor.clearColor().CGColor
        }
    }
    
    /*
    注意：这里是使用addTarget方法的入口，class的初始化必须在主函数之中
    */
    func cellTapped(sender: UIButton) {
        myCellTapped(sender)
    }
}

// 定义单个Item的动态按钮
class SudokuItemButton: NSObject {
    var value: Int                          // 定义了ItemButton的Title是1...9
    var button: UIButton = UIButton()
    
    init(value: Int) {
        /*
        初始化ItemButton的value是1...9，而按钮数组的编号是0...8        
        */
        self.value = value
    }
    
    func createButton(baseView: UIView) {
        button.frame = CGRectMake(CGFloat(-10 + value * 32), 410, 28, 28)
        button.tag = value
        button.addTarget(self, action: "itemTapped:", forControlEvents: UIControlEvents.TouchDown)
        baseView.addSubview(button)             // 注意，这里没有showButton，一是入参type不好确定，二是后续调用ItemGroup时也要show
    }
    
    func showButton(type: SudokuItemButtonType) {
        switch type {
        case SudokuItemButtonType.waitingForSubmit :
            button.enabled = true
            button.setTitle(String(value), forState: .Normal)
            button.setTitleColor(UIColor.whiteColor(), forState:.Normal)
            button.backgroundColor=UIColor.brownColor()
            button.layer.borderWidth = 0
        case SudokuItemButtonType.selected :
            button.enabled = true
            button.setTitle(String(value), forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState:.Normal)
            button.backgroundColor = UIColor.whiteColor()
            button.layer.borderWidth = 0
        case SudokuItemButtonType.available :
            button.enabled = true
            button.setTitle(String(value), forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState:.Normal)
            button.backgroundColor = UIColor.clearColor()
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 1
        case SudokuItemButtonType.disable :
            button.setTitle(String(value), forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState:.Normal)
            button.backgroundColor = UIColor.clearColor()
            button.enabled = false
        }
    }
    
    func itemTapped(sender: UIButton) {
        /*
        注意：这里是使用addTarget方法的入口，class的初始化必须在主函数之中
        */
        myItemTapped(sender)
    }
}

