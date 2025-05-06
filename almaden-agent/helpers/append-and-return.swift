//
//  append-and-return.swift
//  almaden-agent
//
//  Created by Gabriel Hoppe on 24/04/25.
//

import Foundation

func append_and_return<T>(_ target: T, _ array: inout [T]) -> Int {
    
    array.append(target); return array.count - 1;
    
}
