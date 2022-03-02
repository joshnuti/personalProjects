function write-color {
    <#
    .SYNOPSIS
    Enables support to write multiple color text on a single line
    .DESCRIPTION
    Users color codes to enable support to write multiple color text on a single line
    ################################################
    # Write-Color Color Codes
    ################################################
    # ^cn = Normal Output Color
    # ^ck = Black
    # ^cb = Blue
    # ^cc = Cyan
    # ^ce = Gray
    # ^cg = Green
    # ^cm = Magenta
    # ^cr = Red
    # ^cw = White
    # ^cy = Yellow
    # ^cB = DarkBlue
    # ^cC = DarkCyan
    # ^cE = DarkGray
    # ^cG = DarkGreen
    # ^cM = DarkMagenta
    # ^cR = DarkRed
    # ^cY = DarkYellow [Unsupported in Powershell]
    ################################################
    .PARAMETER text
    Mandatory. Line of text to write
    .INPUTS
    [string]$text
    .OUTPUTS
    None
    .NOTES
    Version:        1.0
    Author:         Brian Clark
    Creation Date:  01/21/2017
    Purpose/Change: Initial function development
    Version:        1.1
    Author:         Brian Clark
    Creation Date:  01/23/2017
    Purpose/Change: Fix Gray / Code Format Fixes
    .EXAMPLE
    Write-Color "Hey look ^crThis is red ^cgAnd this is green!"
#>
    
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)][string]$text
    )
        
    ### If $text contains no color codes just write-host as normal
    if (-not $text.Contains("^c")) {
        Write-Host "$($text)"
        return
    }
    
    
    ### Set to true if the beginning of $text is a color code. The reason for this is that
    ### the generated array will have an empty/null value for the first element in the array
    ### if this is the case.
    ### Since we also assume that the first character of a split string is a color code we
    ### also need to know if it is, in fact, a color code or if it is a legitimate character.
    $blnStartsWithColor = $false
    if ($text.StartsWith("^c")) { 
        $blnStartsWithColor = $true 
    }
    
    ### Split the array based on our color code delimeter
    $strArray = $text -split "\^c"
    ### Loop Counter so we can generate a new empty line on the last element of the loop
    $count = 1
    
    ### Loop through the array 
    $strArray | ForEach-Object {
        if ($count -eq 1 -and $blnStartsWithColor -eq $false) {
            Write-Host $_ -NoNewline
            $count++
        }
        elseif ($_.Length -eq 0) {
            $count++
        }
        else {
    
            $char = $_.Substring(0, 1)
            $color = ""
            switch -CaseSensitive ($char) {
                "b" { $color = "Blue" }
                "B" { $color = "DarkBlue" }
                "c" { $color = "Cyan" }
                "C" { $color = "DarkCyan" }
                "e" { $color = "Gray" }
                "E" { $color = "DarkGray" }
                "g" { $color = "Green" }
                "G" { $color = "DarkGreen" }
                "k" { $color = "Black" }
                "m" { $color = "Magenta" }
                "M" { $color = "DarkMagenta" }
                "r" { $color = "Red" }
                "R" { $color = "DarkRed" }
                "w" { $color = "White" }
                "y" { $color = "Yellow" }
                "Y" { $color = "DarkYellow" }
            }
    
            ### If $color is empty write a Normal line without ForgroundColor Option
            ### else write our colored line without a new line.
            if ($color -eq "") {
                Write-Host $_.Substring(1) -NoNewline
            }
            else {
                Write-Host $_.Substring(1) -NoNewline -ForegroundColor $color
            }
            ### Last element in the array writes a blank line.
            if ($count -eq $strArray.Count) {
                Write-Host ""
            }
            $count++
        }
    }
}

function out-log {
    Param(
        [Parameter(Mandatory)][string]$string
    )

    add-content $global:logPath $string
}

class square {
    [int] $id
    [int] $number
    [int] $row
    [int] $column
    [hashtable]$square
    [hashtable]$output
    $options
    [int]$depth

    square(
        $number,
        $row,
        $column,
        $depth
    ) {
        $this.id = $row * 9 + $column
        $this.number = $number
        $this.row = $row
        $this.column = $column
        $this.output = @{}
        $this.depth = $depth

        if ($number -eq 0 -or $number -eq '0') {
            $this.output.color = "^cb"            
            $this.output.num = " "
            $this.options = new-object System.Collections.ArrayList(, @(1, 2, 3, 4, 5, 6, 7, 8, 9))
        }
        else {
            $this.output.color = ""
            $this.output.num = $number
            $this.options = $false
        }

        $this.square = @{
            sq     = & {
                $a = 0
                if ($this.row -in 0..2) { $a = 0 }
                elseif ($this.row -in 3..5) { $a = 3 }
                elseif ($this.row -in 6..8) { $a = 6 }

                $b = 0
                if ($this.column -in 0..2) { $b = 0 }
                elseif ($this.column -in 3..5) { $b = 1 }
                elseif ($this.column -in 6..8) { $b = 2 }
                
                $a + $b
            }
            indice = & {
                $a = 0
                if ($this.column -in @(0, 3, 6)) { $a = 0 }
                elseif ($this.column -in @(1, 4, 7)) { $a = 1 }
                elseif ($this.column -in @(2, 5, 8)) { $a = 2 }
    
                $b = 0
                if ($this.row % 3 -eq 0) { $b = 0 }
                elseif ($this.row % 3 -eq 1) { $b = 3 }
                elseif ($this.row % 3 -eq 2) { $b = 6 }
    
                $a + $b
            }
        }

        if ($this.square.indice -in (2, 5, 8)) {
            $this.output.separator = "┃"
        }
        else {
            $this.output.separator = "│"
        }
    }

    square(
        [square]$square,
        [int]$depth
    ) {
        $this.id = $square.id
        $this.number = $square.number
        $this.row = $square.row
        $this.column = $square.column
        $this.square = $square.square.clone()
        $this.output = $square.output.clone()
        $this.depth = $depth

        if ($square.options) {
            $this.options = $square.options.clone()
        }
        else {
            $this.options = $false
        }
        
        if ($this.output.color -ne '' -and $this.options -ne $false) {
            switch ($depth) {
                2 { $this.output.color = "^cr" }
                3 { $this.output.color = "^cm" }
                4 { $this.output.color = "^cg" }
                5 { $this.output.color = "^cB" }
                6 { $this.output.color = "^cR" }
                7 { $this.output.color = "^cM" }
                8 { $this.output.color = "^cG" }
                Default: { $this.output.color = "^cc" }
            }
        }
    }

    [int] getOptions ($board) {
        $($board.rows[$this.row].number + $board.columns[$this.column].number + $board.squares[$this.square.sq].number | select-object -unique) | foreach-object {
            $this.options.remove($_)
        }

        return $this.options.count
    }

    [int] solveSquare($board) {
        [void] $this.getOptions($board)

        if ($this.options.count -eq 1) {
            $this.updateNumber($this.options[0])
            out-log "$("  "*$this.depth)updateSquare $($this.row).$($this.column) to $($this.number)"
            clear-host
            $board.print()
            return 1
        }

        return 0
    }

    [void] updateNumber($number) {
        $this.number = $number
        $this.output.num = $number
        $this.options = $false
        
    }
}

class board {
    [square[]]$grid
    [square[][]]$rows
    [square[][]]$columns
    [square[][]]$squares
    [boolean] $returnStatus
    [int]$depth
    [int]$maxDepth

    board(
        [string[]]$board
    ) {

        $this.depth = 1
        $this.maxDepth = 2
        $this.returnStatus = $false

        $this.grid = @()
        foreach ($row in 0..8) {
            foreach ($col in 0..8) {
                $this.grid += [square]::new([int]($board[$row][$col]).toString(), $row, $col, 1)
            }
        }

        $this.init()
    }

    board(
        [board]$board
    ) {
        $this.depth = $board.depth + 1
        $this.maxDepth = $board.maxDepth
        $this.returnStatus = $false

        $this.grid = @()
        foreach ($indice in $board.grid) {
            $this.grid += [square]::new($indice, $this.depth)
        }

        $this.init()
    }



    [void] init() {
        $this.rows = & {
            $tempRows = @(@(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0),
                @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0),
                @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0))

            foreach ($row in 0..8) {
                foreach ($col in 0..8) {
                    $tempRows[$row][$col] = $this.grid | where-object { $_.row -eq $row -and $_.column -eq $col }

                }
            }
            return $tempRows
        }

        $this.columns = & {
            $tempColumns = @(@(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0),
                @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0),
                @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0))

            foreach ($col in 0..8) {
                foreach ($row in 0..8) {
                    $tempColumns[$col][$row] = $this.grid | where-object { $_.row -eq $row -and $_.column -eq $col }
                }
            }
            return $tempColumns
        }

        $this.squares = & {
            $tempSquares = @(@(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0),
                @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0),
                @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0), @(0, 0, 0, 0, 0, 0, 0, 0, 0))

            foreach ($square in 0..8) {
                foreach ($indice in 0..8) {
                    $tempSquares[$square][$indice] = $this.grid | where-object { $_.square.sq -eq $square -and $_.square.indice -eq $indice }
                }
            }
            return $tempSquares
        }
    }

    [boolean] complete () {
        if ($this.grid.number.contains(0)) {
            return $false
        }
        else {
            return $true
        }
    }

    [void] printRows() {
        foreach ($rowLine in $this.rows) {
            write-host "|$($rowLine.number -replace 0,' ' -join '|')|"
        }
    }

    [void] printColumns() {
        foreach ($colLine in $this.columns) {
            write-host "|$($colLine.number -replace 0,' ' -join '|')|"
        }
    }

    [void] printSquares() {
        foreach ($line in $this.squares) {
            write-host "|$($line.number -replace 0,' ' -join '|')|"
        }
    }

    [void] print() {
        $output = "┏━━━┯━━━┯━━━┳━━━┯━━━┯━━━┳━━━┯━━━┯━━━┓`r`n"
        foreach ($l in 0..8) {
            $output += "┃ "

            $line = $this.rows[$l]
            foreach ($i in $line) {
                $output += "$($i.output.color)$($i.output.num)^cn $($i.output.separator) "
            }

            if ((($l + 1) % 3 -eq 0) -and ($l -ne 8)) {
                $output += "`r`n┣━━━┿━━━┿━━━╋━━━┿━━━┿━━━╋━━━┿━━━┿━━━┫`r`n"
            }
            elseif ($l -ne 8) {
                $output += "`r`n┠───┼───┼───╂───┼───┼───╂───┼───┼───┨`r`n"
            }
        }
        $output += "`r`n┗━━━┷━━━┷━━━┻━━━┷━━━┷━━━┻━━━┷━━━┷━━━┛"

        write-color $output
    }

    [void] logBoard() {
        $output = "┏━━━┯━━━┯━━━┳━━━┯━━━┯━━━┳━━━┯━━━┯━━━┓`r`n"
        foreach ($l in 0..8) {
            $output += "┃ $($this.rows[$l].output.num[0..2] -join " │ ") ┃ $($this.rows[$l].output.num[3..5] -join " │ ") ┃ $($this.rows[$l].output.num[6..8] -join " │ ") ┃"

            if ((($l + 1) % 3 -eq 0) -and ($l -ne 8)) {
                $output += "`r`n┣━━━┿━━━┿━━━╋━━━┿━━━┿━━━╋━━━┿━━━┿━━━┫`r`n"
            }
            elseif ($l -ne 8) {
                $output += "`r`n┠───┼───┼───╂───┼───┼───╂───┼───┼───┨`r`n"
            }
        }
        $output += "`r`n┗━━━┷━━━┷━━━┻━━━┷━━━┷━━━┻━━━┷━━━┷━━━┛"

        out-log $output
    }

    [void] logOptions() {
        out-log "r.c {<options>}"
        $this.grid | where-object { $_.options -ne $false } | foreach-object { out-log "$($_.row).$($_.column) [$($_.options -join ',')]" }
    }

    [int] solveRows() {
        return $this.solveLine($this.rows, "Rows")
    }

    [int] solveColumns() {
        return $this.solveLine($this.columns, "Columns")
    }

    [int] solveSquares() {
        return $this.solveLine($this.squares, "Squares")
    }

    [int] solveLine($iterator, $type) {
        $prevCount = -1
        $count = -2

        $changes = 0

        while ($prevCount -ne $count) {
            $prevCount = $count

            $count = 0
            $iterator | foreach-object {
                $tempOptions = @{}
                $nos = @()

                foreach ($indice in $($_ | where-object options -ne $false)) {
                    $indice.getOptions($this)

                    foreach ($option in $indice.options) {
                        if ($null -eq $tempOptions[$option] -and $option -notin $nos) {
                            $tempOptions[$option] = $indice
                        }
                        else {
                            $tempOptions.remove($option)
                            $nos += $option
                        }
                    }
                }

                if ($tempOptions.keys.count -gt 0) {
                    foreach ($option in $tempOptions.keys) {
                        $tempOptions[$option].updateNumber($option)
                        out-log "$("  "*$this.depth)update$type $($tempOptions[$option].row).$($tempOptions[$option].column) to $($tempOptions[$option].number)"
                        clear-host
                        $this.print()
                        $changes++
                    }
                }
            }
        }

        return $changes
    }

    [int] solveEach() {
        $prevChanges = -1
        $changes = 0
        $overallChanges = 0

        while ($prevChanges -ne $changes) {
            $overallChanges += $changes
            $prevChanges = $changes
            $changes = 0

            $this.grid | where-object options -ne $false | foreach-object {
                if ($_.options) {
                    $changes += $_.solveSquare($this)
                }
            }
        }

        return $overallChanges
    }

    [boolean] solve() {
        $pass = 0
        $changes = -1

        while ($changes -ne 0 -and !$this.complete()) {
            $pass++
            $changes = 0

            out-log "$("  "*$($this.depth - 1))Pass #$pass"

            $changes += $this.solveEach()
            $changes += $this.solveRows()
            $changes += $this.solveColumns()
            $changes += $this.solveSquares()

            if ($changes -gt 0) {
                out-log "  $changes Indices Changed"
                if ($this.complete()) {
                    return $true
                    out-log "Final Status: Success"
                    out-log ""
                }
            }
            else {
                return $false
                out-log "No Changes Found"
            }
        }

        out-log "Final Status: Failure"
        return $false
    }

    [board] solveRecursive($maxDepth) {
        foreach ($indice in $($this.grid | where-object { $_.options -ne $false })) {
            foreach ($option in $indice.options) {
                write-host "Location: $($indice.row).$($indice.column) Option: $option Depth: $($this.depth)"
                out-log "$("  "*$($this.depth - 1))Recurse: Location: $($indice.row).$($indice.column) Option: $option Depth: $($this.depth)"

                $testBoard = $this.clone()

                ($testBoard.grid | where-object { $_.id -eq $indice.id }).updateNumber($option)

                if ($testboard.solve()) {
                    $testBoard.returnStatus = $true
                    return $testBoard
                }
                else {
                    if ($testBoard.depth + 1 -le $maxDepth) {
                        $testBoard.solveRecursive($maxDepth)
                    }
                }    
            }
        }
        return $this
    }


    [board] clone() {
        return [board]::new($this)
    }
}
function solve {
    Param(
        [string[]]$boardInput
    )

    $stopwatch = [system.diagnostics.stopwatch]::StartNew()

    $board = [board]::new($boardInput)

    $board.logBoard()
    $board.print()

    # read-host

    $pass1 = $board.solve()

    

    if (!$pass1) {
        # read-host
        $passTest = $false
        $depth = 2

        while (!$passTest -and $depth -le 10) {
            $passTest = $($board.solveRecursive($depth)).returnStatus
            $depth++
            
        }
    }

    $board.logBoard()

    $stopwatch.Stop()
    out-log "$($stopwatch.elapsed.totalSeconds) seconds elapsed"

    # read-host
    
}

function solveTXTPuzzles {
    $puzzlesPath = "$PSScriptRoot/puzzles"

    get-childitem $puzzlesPath -exclude *log* | select-object -first 10 | foreach-object {
        $boardTXT = @()

        $content = get-content $_.FullName
        0..8 | foreach-object {
            $boardTXT += $content[$_].replace(" ", "").replace(".", "0")
        }

        $global:logPath = "$($_.FullName -replace $_.name,'')/logs/$($_.Name -replace '.txt','')_log.txt"

        $_.FullName | out-file $global:logPath

        solve($boardTXT)
    }
}

function solveInput {
    $boardInput = @()

    0..8 | foreach-object {
        $tempInput = read-host "Line $($_+1)"
        $boardInput += $tempInput
    }

    solve($boardInput)
}

solveTXTPuzzles