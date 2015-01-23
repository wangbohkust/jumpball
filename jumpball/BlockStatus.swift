//
//  BlockStatus.swift
//  jumpball
//
//  Created by wangbo on 1/16/15.
//  Copyright (c) 2015 wangbo. All rights reserved.
//

import Foundation

class BlockStatus  {
    var isRunning = false
    var timeGapForNextRun = UInt32(0)
    var currentInterval = UInt32(0)
    init(isRunning:Bool, timeGapForNextRun:UInt32, currentInterval:UInt32){
        self.currentInterval = currentInterval
        self.isRunning = isRunning
        self.timeGapForNextRun = timeGapForNextRun
    }
    
    func shouldRunBlock() -> Bool{
        return self.currentInterval > self.timeGapForNextRun
    }
}