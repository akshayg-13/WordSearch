import Foundation

enum WordSearch {
    
    case easy, medium, hard
    
    public func createWordSearch(withWords words : [String]) -> [String] {
        let cells = createCells(withWords: words)
        return getWordSearchGrid(cells: cells)
    }
}

private extension WordSearch {
    
    static private let nRows:Int = 12
    static private let nCols:Int = 12
    static private let gridSize = nRows * nCols
    static private let dirs = [[1,0],[0,1],[1,1],[1,-1],[-1,0],[0,-1],[-1,-1],[-1,1]]
    
    private func createCells(withWords words : [String]) -> [[Character]] {
        var cells: [[Character]] = [[Character]](repeating: [Character](repeating: " ", count: WordSearch.nCols), count: WordSearch.nRows)
        let tempChar : [Character] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        var cellsFilled = 0
        for word in words {
            cellsFilled += tryPlaceWord(cells: &cells, word: word.uppercased())
        }
        
        if self != .easy {
            let remaining = WordSearch.gridSize - cellsFilled
            for word in getDummyWords(from: words, remainingSpace: remaining) {
                cellsFilled += tryPlaceWord(cells: &cells, word: word)
            }
        }
        
        for (idx1,row) in cells.enumerated() {
            for (idx2,_) in row.enumerated() {
                if cells[idx1][idx2] == Character(" ") {
                    cells[idx1][idx2] = tempChar.randomElement() ?? "A"
                }
            }
        }
        
        return cells
    }
    
    private func getDummyWords(from words : [String], remainingSpace : Int) -> [String] {
        var randomWords : [String] = []
        
        if self == .hard {
            for each in words {
                let randomIndex = Int.random(in: 0..<each.count - 1)
                let word1 = each.substring(toIndex: randomIndex)
                let word2 = each.substring(fromIndex: randomIndex)
                if word1.count == word2.count {
                    randomWords.append(String((word1+word2).prefix(8)).uppercased())
                } else {
                    randomWords.append(word1.uppercased())
                }
            }
        }
        
        var count = randomWords.joined().count
        while count < remainingSpace {
            let staticWord = getStaticWord
            let diff = remainingSpace - randomWords.joined().count
            if staticWord.count <= diff {
                randomWords.append(staticWord.uppercased())
            } else {
                let partialWord = staticWord.prefix(diff)
                randomWords.append(String(partialWord).uppercased())
            }
            count = randomWords.joined().count
        }
        
        return randomWords
    }
    
    private var getStaticWord : String {
        let words = ["closed", "haunt", "woman", "zephyr","wacky", "acrid", "dinner", "intelligent", "reading", "mean", "sidewalk", "pour", "destroy", "quicksand", "wholesale", "accurate", "seemly", "remember", "berry", "shiny", "turn", "needless", "zoom", "fly", "mitten", "synonymous", "wealthy", "sassy", "angle", "cabbage", "sordid", "nutty", "coal", "crazy", "pig", "brass", "blood", "comfortable", "island", "note", "snobbish", "smile", "barbarous", "crib", "rail", "curl", "paste", "part", "sulky"]
        let randomIndex = Int.random(in: 0..<words.count)
        return words[randomIndex]
    }
    
    private func placeMessage(cells: inout[[Character]], msg: String) -> Int {
        let msg = msg.uppercased()
        let messageLen = msg.count
        if messageLen > 0 && messageLen < WordSearch.gridSize {
            let gapSize = Int(WordSearch.gridSize / messageLen)
            for i in 0..<messageLen {
                let pos = i * gapSize + Int.random(in: 0..<gapSize)
                cells[Int(pos / WordSearch.nCols)][pos % WordSearch.nCols] = Character(msg[i])
            }
            return messageLen
        }
        return 0
    }
    
    private func tryPlaceWord(cells: inout[[Character]], word: String) -> Int {
        var dir:Int!
        var pos:Int!
        let randDir = Int.random(in: 0..<WordSearch.dirs.count)
        let randPos = Int.random(in: 0..<WordSearch.gridSize)
        for i in 0..<WordSearch.dirs.count {
            dir = (i + randDir) % WordSearch.dirs.count
            for j in 0..<WordSearch.gridSize {
                pos = (j + randPos) % WordSearch.gridSize
                let lettersPlaced = tryLocation(cells: &cells, word: word, dir: dir, pos: pos)
                if lettersPlaced > 0 { return lettersPlaced }
            }
        }
        return 0
    }
    
    private func tryLocation(cells: inout[[Character]], word: String, dir: Int, pos: Int) -> Int {
        let r = pos/12
        let c = pos%12
        let len = word.count
        var rr = r
        var cc = c
        var overlaps = 0

        if ((WordSearch.dirs[dir][0] == 1 && (len + c) > WordSearch.nCols)
            || (WordSearch.dirs[dir][0] == -1 && (len - 1) > c)
            || (WordSearch.dirs[dir][1] == 1 && (len + r) > WordSearch.nRows)
            || (WordSearch.dirs[dir][1] == -1 && (len - 1) > r)) {
            return 0
        }

        for i in 0..<len {
            let emptyCheck = !String(cells[rr][cc]).isEmpty
            let charCheck = String(cells[rr][cc]) != word[i]
            if emptyCheck && charCheck { return 0 }
            cc += WordSearch.dirs[dir][0]
            rr += WordSearch.dirs[dir][1]
        }
        cc = c
        rr = r

        for i in 0..<len {
            if cells[rr][cc] == Character(word[i]) {
                overlaps += 1
            } else {
                cells[rr][cc] = Character(word[i])
            }
            if (i < len - 1) {
                cc += WordSearch.dirs[dir][0];
                rr += WordSearch.dirs[dir][1];
            }
        }
        
        return len - overlaps
    }
    
    private func getWordSearchGrid(cells: [[Character]]) -> [String] {
        var tempResult = [String]()
        
        for row in 0..<WordSearch.nRows{
            for column in 0..<WordSearch.nCols{
                tempResult.append(String(cells[row][column]))
            }
        }
        return tempResult
    }
}

extension String {
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, count) ..< count]
    }
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                            upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
