//
//  ViewController.swift
//  MySudoku
//
//  Created by imac on 15/12/29.
//  Copyright © 2015年 caogo.cn. All rights reserved.
//

import UIKit

/*
    定义所有的全局变量
*/
var SDKCellMatrix = SudokuCellMatrix()                  // 81个cell按钮的矩阵
var SDKItemGroup = SudokuItemGroup()                    // 9个item按钮
var SDKModeSwitch = SudokuModeSwitch()                  // 1个mode开关


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
            注意：这里就是主程序的入口，具体实现时初始化了三个全局calss，并展开frame布局
        */
        myInitFrame()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func myInitFrame() {
        
        SDKModeSwitch.createButton(self.view)
        
        let exam = SudokuSubject()
        exam.example()
        SDKCellMatrix.loadSubject(self.view , subject: exam)
        
        SDKItemGroup.createGroup(self.view)
        SDKItemGroup.showGroup(SudokuItemButtonType.waitingForSubmit)
    }


}


/*
    定义最关键的三个事件管理函数，用于控制所有的动作，
    调用点是UIButton的addTarget触发函数，如SudokuCellButton.cellTappped()只有一行代码：myCellTapped(sender.tag)
*/
func myCellTapped(sender: UIButton) {
    print("Warning: Cell button tapped, sender is \(sender.tag)")
    
    SDKCellMatrix.updateIndex(sender.tag)
    let index = SDKCellMatrix.index
    if index == nil { return }
    
    let cell = SDKCellMatrix.matrix[index!]             //  小心一点！！！ index可能为nil并导致matrix数组越界
    
    switch SDKModeSwitch.globeMode {
    case .submitting :
        SDKItemGroup.showGroup(SudokuItemButtonType.waitingForSubmit)
    case .selecting  :
        switch cell.status {
        case .initialized,.submitted :
            SDKItemGroup.showGroup(SudokuItemButtonType.disable)
        case .unsubmitted :
            SDKItemGroup.showGroup(cell.candidateList)
        }
    }
}

func myItemTapped(sender: UIButton) {
    print("Warning: Item button tapped, sender is \(sender.tag)")
    
    let itemValue = sender.tag
    let index = SDKCellMatrix.index
    if index == nil { return }
    
    let cell = SDKCellMatrix.matrix[index!]         //  小心一点！！！ index可能为nil并导致matrix数组越界
    
    switch SDKModeSwitch.globeMode {
    case SudokuGlobeMode.submitting :
        switch cell.status {
        case .unsubmitted :
            if !cell.isRightValue(itemValue) { print("Warning: submit \(itemValue) is a wrong answer!"); return }
            cell.commitValue(itemValue)
            cell.showButton()                       // 刚刚修改了Cell的vlaue，button的标题必须刷新
            SDKCellMatrix.updateIndex(index!)
        case .initialized, .submitted : break
        }
    case SudokuGlobeMode.selecting :
        switch SDKItemGroup.itemGroup[sender.tag - 1].type {
        case .available :
            if !cell.insertCandidate(itemValue) { print("Warning: insert candidate failed ....."); return }
        case .selected :
            if !cell.removeCandidate(itemValue) { print("Warning: remove candidate failed ....."); return}
        default : break
        }
        
        cell.showButton()                           // 刚刚修改了Cell的candidateList，button的标题必须刷新
        SDKItemGroup.showGroup(cell.candidateList)
    }
}

func mySwitchTapped(sender: UIButton) {
    print("Warning: Switch button tapped, sender is \(sender.tag)")
    
    switch SDKModeSwitch.globeMode {
    case SudokuGlobeMode.submitting :
        SDKModeSwitch.globeMode = SudokuGlobeMode.selecting
        SDKCellMatrix.updateIndex(nil)
        SDKItemGroup.showGroup(SudokuItemButtonType.disable)
    case SudokuGlobeMode.selecting :
        SDKModeSwitch.globeMode = SudokuGlobeMode.submitting
        SDKCellMatrix.updateIndex(nil)
        SDKItemGroup.showGroup(SudokuItemButtonType.waitingForSubmit)
    }
    
    SDKModeSwitch.showButton()
}





