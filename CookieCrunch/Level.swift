//
//  Level.swift
//  CookieCrunch
//
//  Created by indianic on 16/11/17.
//  Copyright © 2017 indianic. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9
let NumLevels = 4

class Level
{
    fileprivate var cookies = Array2d<Cookie>(columns : NumColumns, rows : NumRows)
    private var tiles = Array2d<Tile>(columns : NumColumns, rows : NumRows)
    
    private var possibleSwaps = Set<Swap>()
    
    init(filename: String)
    {
        //1
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) else {return}
        //2
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else {return}
        //3
        for (row, rowArray) in tilesArray.enumerated()
        {
            //4
            let tileRow = NumRows - row - 1
            //5
            for(column, value) in rowArray.enumerated()
            {
                if value == 1
                {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
    }
    
    func cookieAt(column: Int, row : Int) -> Cookie?
    {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return cookies[column, row]
    }
    
    func tileAt(column : Int, row : Int) -> Tile?
    {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func shuffle() -> Set<Cookie>
    {
        var set : Set<Cookie>
        repeat
        {
            set = createInitialCookies()
            detectPossibleSwaps()
            print("possible swaps: \(possibleSwaps)")
        }
        while possibleSwaps.count == 0
        
        return set
    }
    
    private func createInitialCookies() -> Set<Cookie>
    {
        var set = Set<Cookie>()
        
        for row in 0..<NumRows
        {
            for column in 0..<NumColumns
            {
                if tiles[column, row] != nil
                {
//                    var cookieType = CookieType.random()
                    var cookieType: CookieType
                    repeat
                    {
                        cookieType = CookieType.random()
                    }
                    while (column >= 2 &&
                        cookies[column - 1, row]?.cookieType == cookieType &&
                        cookies[column - 2, row]?.cookieType == cookieType)
                        || (row >= 2 &&
                            cookies[column, row - 1]?.cookieType == cookieType &&
                            cookies[column, row - 2]?.cookieType == cookieType)
                    
                    
                    let cookie = Cookie(column : column, row: row, cookieType : cookieType)
                    cookies[column, row] = cookie
                    
                    set.insert(cookie)
                }
            }
        }
        
        return set
    }
    
    func performSwap(swap : Swap)
    {
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }
    
    private func hasChainAt(column : Int, row : Int) -> Bool
    {
        let cookieType = cookies[column, row]!.cookieType
        
        //Horizontal chain check
        var horzLength = 1
        
        //Left
        var i = column - 1
        while i >= 0 && cookies[i, row]?.cookieType == cookieType
        {
            i -= 1
            horzLength += 1
        }
        
        //Right
        i = column + 1
        while i < NumColumns && cookies[i, row]?.cookieType == cookieType
        {
            i += 1
            horzLength += 1
        }
        if horzLength >= 3 { return true }
        
        //Vertical chain check
        var vertLength = 1
        
        //Down
        i = row - 1
        while i >= 0 && cookies[column, i]?.cookieType == cookieType
        {
            i -= 1
            vertLength += 1
        }
        
        //Up
        i = row + 1
        while i < NumRows && cookies[column, i]?.cookieType == cookieType
        {
            i += 1
            vertLength += 1
        }
        return vertLength >= 3
    }
    
    func detectPossibleSwaps()
    {
        var set = Set<Swap>()
        
        for row in 0..<NumRows
        {
            for column in 0..<NumColumns
            {
                if let cookie = cookies[column, row]
                {
                    //TODO: detection logic goes here
                    //Is it possible to swap this cookie with one on the right?
                    if column < NumColumns - 1
                    {
                        //Have a cookie in this spot? If there is no tile, there is no cookie
                        if let other = cookies[column + 1 , row]
                        {
                            //Swap them
                            cookies[column, row] = other
                            cookies[column + 1, row] = cookie
                            
                            //Is either cookie now a part of a chain?
                            if hasChainAt(column: column + 1, row: row) || hasChainAt(column: column, row: row)
                            {
                                set.insert(Swap(cookieA : cookie, cookieB : other))
                            }
                            
                            //Swap them back
                            cookies[column, row] = cookie
                            cookies[column + 1, row] = other
                        }
                    }
                    
                    if row < NumRows - 1
                    {
                        if let other = cookies[column, row + 1]
                        {
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie
                            
                            // Is either cookie now part of a chain?
                            if hasChainAt(column: column, row: row + 1) || hasChainAt(column: column, row: row)
                            {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            // Swap them back
                            cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                        }
                    }
                }
            }
        }
        
        possibleSwaps = set
    }
    
    func isPossibleSwap(_ swap : Swap) -> Bool
    {
        return possibleSwaps.contains(swap)
    }
    
    private func detectHorizontalMatches() -> Set<Chain>
    {
        // 1
        var set = Set<Chain>()
        // 2
        for row in 0..<NumRows
        {
            var column = 0
            while column < NumColumns-2
            {
                // 3
                if let cookie = cookies[column, row]
                {
                    let matchType = cookie.cookieType
                    // 4
                    if cookies[column + 1, row]?.cookieType == matchType && cookies[column + 2, row]?.cookieType == matchType
                    {
                        // 5
                        let chain = Chain(chainType: .horizontal)
                        repeat
                        {
                            chain.add(cookie: cookies[column, row]!)
                            column += 1
                        }
                        while column < NumColumns && cookies[column, row]?.cookieType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
                // 6
                column += 1
            }
        }
        return set
    }
    
    private func detectVerticalMatches() -> Set<Chain>
    {
        var set = Set<Chain>()
        
        for column in 0..<NumColumns
        {
            var row = 0
            while row < NumRows-2
            {
                if let cookie = cookies[column, row]
                {
                    let matchType = cookie.cookieType
                    
                    if cookies[column, row + 1]?.cookieType == matchType && cookies[column, row + 2]?.cookieType == matchType
                    {
                        let chain = Chain(chainType: .vertical)
                        repeat
                        {
                            chain.add(cookie: cookies[column, row]!)
                            row += 1
                        }
                        while row < NumRows && cookies[column, row]?.cookieType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
                row += 1
            }
        }
        return set
    }
    
    func removeMatches() -> Set<Chain>
    {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        print("Horizontal matches: \(horizontalChains)")
        removeCookies(chains: horizontalChains)
        print("Vertical matches: \(verticalChains)")
        removeCookies(chains: verticalChains)
        
        return horizontalChains.union(verticalChains)
    }
    
    private func removeCookies(chains: Set<Chain>)
    {
        for chain in chains
        {
            for cookie in chain.cookies
            {
                cookies[cookie.column, cookie.row] = nil
            }
        }
    }
    
    func fillHoles() -> [[Cookie]]
    {
        var columns = [[Cookie]]()
        // 1
        for column in 0..<NumColumns
        {
            var array = [Cookie]()
            for row in 0..<NumRows
            {
                // 2
                if tiles[column, row] != nil && cookies[column, row] == nil
                {
                    // 3
                    for lookup in (row + 1)..<NumRows
                    {
                        if let cookie = cookies[column, lookup]
                        {
                            // 4
                            cookies[column, lookup] = nil
                            cookies[column, row] = cookie
                            cookie.row = row
                            // 5
                            array.append(cookie)
                            // 6
                            break
                        }
                    }
                }
            }
            // 7
            if !array.isEmpty
            {
                columns.append(array)
            }
        }
        return columns
    }
    
    func topUpCookies() -> [[Cookie]]
    {
        var columns = [[Cookie]]()
        var cookieType: CookieType = .unknown
        
        for column in 0..<NumColumns
        {
            var array = [Cookie]()
            
            // 1
            var row = NumRows - 1
            while row >= 0 && cookies[column, row] == nil
            {
                // 2
                if tiles[column, row] != nil
                {
                    // 3
                    var newCookieType: CookieType
                    repeat {
                        newCookieType = CookieType.random()
                    } while newCookieType == cookieType
                    cookieType = newCookieType
                    // 4
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    array.append(cookie)
                }
                
                row -= 1
            }
            // 5
            if !array.isEmpty
            {
                columns.append(array)
            }
        }
        return columns
    }

}
