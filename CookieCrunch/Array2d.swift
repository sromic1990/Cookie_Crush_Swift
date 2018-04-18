//
//  Array2d.swift
//  CookieCrunch
//
//  Created by indianic on 16/11/17.
//  Copyright © 2017 indianic. All rights reserved.
//

struct Array2d<T>
{
    let columns : Int
    let rows : Int
    fileprivate var array : Array<T?>
    
    init(columns : Int, rows : Int)
    {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(repeating : nil, count : rows * columns)
    }
    
    subscript(column : Int, row : Int) -> T?
    {
        get
        {
            return array[row * columns + column]
        }
        set
        {
            array[row * columns + column] = newValue
        }
    }
}
