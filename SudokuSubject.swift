//
//  SudokuSubject.swift
//  MySudoku
//
//  Created by imac on 15/12/29.
//  Copyright © 2015年 caogo.cn. All rights reserved.
//

import Foundation


// 定义数独的题目
class SudokuSubject {
    var cells: [(value: Int, visible: Bool)] = []
    
    func example() {
        self.cells = [
            (1, false), (2, true), (3, true),(4, true), (5, false), (6, true),(7, true), (8, true), (9, false),
            (4, true), (5, true), (6, true),(7, true), (8, true), (9, true),(1, true), (2, true), (3, true),
            (7, true), (8, true), (9, true),(1, true), (2, true), (3, true),(4, true), (5, true), (6, true),
            (2, true), (3, true), (4, true),(5, true), (6, true), (7, true),(8, true), (9, true), (1, true),
            (5, false), (6, true), (7, true),(8, true), (9, false), (1, true),(2, true), (3, true), (4, false),
            (8, true), (9, true), (1, true),(2, true), (3, true), (4, true),(5, true), (6, true), (7, true),
            (3, true), (4, true), (5, true),(6, true), (7, true), (8, true),(9, true), (1, true), (2, true),
            (6, true), (7, true), (8, true),(9, true), (1, true), (2, true),(3, true), (4, true), (5, true),
            (9, false), (1, true), (2, true),(3, true), (4, false), (5, true),(6, true), (7, true), (8, false)]
        
    }
}

