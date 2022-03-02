$host.ui.RawUI.WindowTitle = “Checkers”

$global:logPath = "$PSScriptRoot\checkers log.txt"
out-file $global:logPath

function out-log {
    Param(
        [Parameter(Mandatory)][string]$string
    )

    add-content $global:logPath $string
}

class piece {
    [int]$id
    [int]$team
    [square]$square
    [boolean]$king

    piece(
        [int]$team,
        [square]$square,
        [int]$pieceID
    ) {
        $this.team = $team
        $this.square = $square
        $this.id = $pieceID
        
        $this.king = $false
    }

    [boolean] onBoard() {
        if ($this.square) { return $true }
        else { return $false }
    }

    [object[]] getOptions() {
        if ($this.team -eq 0 -or $this.king) { $down = $true }
        else { $down = $false }
        
        if ($this.team -eq 1 -or $this.king) { $up = $true }
        else { $up = $false }

        $options = @()

        # if direction is not null & not direction piece & can move up/down
        if ($null -ne $this.square.topLeft -and !$this.square.topLeft.piece -and $up) {
            $options += [PSCustomObject]@{square = $this.square.topLeft; piece = $null }
        }
        if ($null -ne $this.square.topRight -and !$this.square.topRight.piece -and $up) {
            $options += [PSCustomObject]@{square = $this.square.topRight; piece = $null }
        }
        if ($null -ne $this.square.bottomLeft -and !$this.square.bottomLeft.piece -and $down) {
            $options += [PSCustomObject]@{square = $this.square.bottomLeft; piece = $null }
        }
        if ($null -ne $this.square.bottomRight -and !$this.square.bottomRight.piece -and $down) {
            $options += [PSCustomObject]@{square = $this.square.bottomRight; piece = $null }
        }

        # if direction has piece & direction piece team != this team & not direction.direction piece & can move up/down
        if ($this.square.topLeft.piece -and $this.square.topLeft.piece.team -ne $this.team -and !$this.square.topLeft.topLeft.piece -and $up) {
            $options += [PSCustomObject]@{square = $this.square.topLeft.topLeft; piece = $this.square.topLeft.piece }
        }
        if ($this.square.topRight.piece -and $this.square.topRight.piece.team -ne $this.team -and !$this.square.topRight.topRight.piece -and $up) {
            $options += [PSCustomObject]@{square = $this.square.topRight.topRight; piece = $this.square.topRight.piece }
        }
        if ($this.square.bottomLeft.piece -and $this.square.bottomLeft.piece.team -ne $this.team -and !$this.square.bottomLeft.bottomLeft.piece -and $down) {
            $options += [PSCustomObject]@{square = $this.square.bottomLeft.bottomLeft; piece = $this.square.bottomLeft.piece } 
        }
        if ($this.square.bottomRight.piece -and $this.square.bottomRight.piece.team -ne $this.team -and !$this.square.bottomRight.bottomRight.piece -and $down) {
            $options += [PSCustomObject]@{square = $this.square.bottomRight.bottomRight; piece = $this.square.bottomRight.piece }
        }

        return $options
    }

    [boolean] move([string] $position) {
        $options = $this.getOptions()

        if ($options.square.position -contains $position) {
            $option = $options | where-object { $_.square.position -eq $position }
            $newSquare = $option.square

            if ($null -ne $option.piece) {
                $option.piece.square.piece = $null
                $option.piece.square = $null
            }

            $this.square.piece = $null
            $newSquare.piece = $this
            $this.square = $newSquare

            if ($this.square.position[0] -eq '7' -and $this.team -eq 0) {
                $this.king = $true
            }
            elseif ($this.square.position[0] -eq '0' -and $this.team -eq 1) {
                $this.king = $true
            }

            return $true
        }
        else {
            return $false
        }
    }
}

class square {
    [int]$id
    [string]$position
    [boolean]$even
    [piece]$piece
    [square]$right
    [square]$topLeft
    [square]$topRight
    [square]$bottomLeft
    [square]$bottomRight

    square(
        [int]$id
    ) {
        if ($id -lt 32) {
            $this.id = $id
            if ([math]::floor($id / 4) % 2 -eq 0) {
                $this.position = "$([math]::floor($id / 4)).$(($id % 4) * 2)"
                $this.even = $true
            }
            else {
                $this.position = "$([math]::floor($id / 4)).$(($id % 4) * 2 + 1)"
                $this.even = $false
            }
            
            $this.right = [square]::new($id + 1)

        }
        else {
            $this.right = $null
        }
    }

    square() {
        $this.id = 0
        $this.position = "0.0"
        $this.even = $true
        $this.right = [square]::new(1)
    }

    [string] output() {
        if ($this.piece.team -eq 0 -and !$this.piece.king) { return '○' }
        elseif ($this.piece.team -eq 0 -and $this.piece.king) { return '♔' }
        elseif ($this.piece.team -eq 1 -and !$this.piece.king) { return '●' }
        elseif ($this.piece.team -eq 1 -and $this.piece.king) { return '♚' }
        else { return ' ' }
    }

    [void] printDetails() {
        write-host "Position:    $($this.position)"
        write-host "TopLeft:     $($this.topLeft.position)"
        write-host "TopRight:    $($this.topRight.position)"
        write-host "BottomLeft:  $($this.bottomLeft.position)"
        write-host "BottomRight: $($this.bottomRight.position)"
    }

}

class player {
    [int]$team
    [piece[]]$pieces
    [boolean]$cpu
    [board]$board

    player(
        [int]$team,
        [board]$board
    ) {
        $this.team = $team
        $this.board = $board
        $this.pieces = @()
    }

    [int] discardedPieces() {
        return ($this.pieces | where-object { !$_.onBoard() }).count
    }

    [piece[]] activePieces() {
        return ($this.pieces | where-object { $_.onBoard() -and $_.getOptions().count -gt 0 }) | sort-object { [int]$_.position }
    }

    [piece] getPiece([int] $id) {
        return $this.pieces[$id]
    }

    [piece] getPiece([string] $position) {
        return $this.pieces | where-object { $_.square.position -eq $position }
    }

    [boolean] movePiece([string]$from, [string] $to) {
        if ($this.getPiece($from)) {
            write-host
            $movePiece = $this.getPiece($from).move($to)
            if ($movePiece) { write-host 'Move Successful' }
            else { write-host 'Invalid Move' }
            start-sleep 1
            return $movePiece
        }
        else {
            write-host 'Invalid Move'
            start-sleep 1
            return $false
        }
    }

    [void] print() {
        # clear-host
        $counter = 0
        write-host "   0  1  2  3  4  5  6  7"
        $this.board.toRows() | foreach-object {
            write-host "$counter " -NoNewline
            $counter++
            $activePieces = $this.activePieces()
            if ([math]::floor($_[0].id / 4) % 2 -eq 0) {
                foreach ($sq in $_) {
                    if ($sq.piece -and $sq.piece -in $activePieces) { $color = 'cyan' }
                    else { $color = 'black' }

                    write-host " $($sq.output()) " -BackgroundColor red -ForegroundColor $color -NoNewline
                    write-host '   ' -NoNewline
                }
            }
            else {
                foreach ($sq in $_) {
                    if ($sq.piece -and $sq.piece -in $activePieces) { $color = 'cyan' }
                    else { $color = 'black' }

                    write-host '   ' -NoNewline
                    write-host " $($sq.output()) " -BackgroundColor red -ForegroundColor $color -NoNewline
                }
            }
            write-host
        }

        $team0 = "$('○' * $this.board.player0.discardedPieces())$(' ' * (8-$this.board.player0.discardedPieces()))"
        $team1 = "$(' ' * (8-$this.board.player1.discardedPieces()))$('●' * $this.board.player1.discardedPieces())"

        write-host "  $team0        $team1"
    }
}

class board {
    hidden [square] $primary
    hidden [piece[]] $pieces
    hidden [player] $player0
    hidden [player] $player1
    hidden $host

    board($hostValue) {
        $this.host = $hostValue

        $this.player0 = [player]::new(0, $this)
        $this.player1 = [player]::new(1, $this)

        $this.pieces = @()

        $this.primary = [square]::new()

        $list = $this.toList()

        $pieceID = 0
        $list | foreach-object {
            if ($_.even) {
                # topLeft     | row != 0 & col != 0
                if ($_.position[0] -ne '0' -and $_.position[2] -ne '0') { $_.topLeft = $list[$_.id - 5] }

                # topRight    | row != 0
                if ($_.position[0] -ne '0') { $_.topRight = $list[$_.id - 4] }

                # bottomLeft  | col != 0
                if ($_.position[2] -ne '0') { $_.bottomLeft = $list[$_.id + 3] }

                # bottomRight | always
                $_.bottomRight = $list[$_.id + 4]
            }
            else {
                # topLeft     | always
                $_.topLeft = $list[$_.id - 4]

                # topRight    | col != 7
                if ($_.position[2] -ne '7') { $_.topRight = $list[$_.id - 3] }

                # bottomLeft  | row != 7 & col != 0
                if ($_.position[0] -ne '7' -and $_.position[2] -ne '0') { $_.bottomLeft = $list[$_.id + 4] }

                # bottomRight | col != 7
                if ($_.position[2] -ne '7') { $_.bottomRight = $list[$_.id + 5] }
            }
            
            if ($_.id -in 0..7) {
                $newPiece = [piece]::new(0, $_, $pieceID)
                $this.pieces += $newPiece
                $_.piece = $newPiece
                $this.player0.pieces += $newPiece
                $pieceID++
            }
            elseif ($_.id -in 24..31) {
                $newPiece = [piece]::new(1, $_, $pieceID)
                $this.pieces += $newPiece
                $_.piece = $newPiece
                $pieceID++
                $this.player1.pieces += $newPiece
            }
        }

        out-log "Board Initialized"
    }

    [void] print($position) {
        # clear-host

        if ($position) {
            $piece = $this.getPiece($position)
            $options = $piece.getOptions().square.position
            $options += $position
        }
        else {
            $options = @()
        }

        $counter = 0
        write-host "   0  1  2  3  4  5  6  7"
        $this.toRows() | foreach-object {
            write-host "$counter " -NoNewline
            $counter++
            if ([math]::floor($_[0].id / 4) % 2 -eq 0) {
                foreach ($sq in $_) {
                    if ($sq.position -in $options) { $backgroundColor = 'white' }
                    else { $backgroundColor = 'red' }

                    write-host " $($sq.output()) " -BackgroundColor $backgroundColor -ForegroundColor black -NoNewline
                    write-host '   ' -NoNewline
                }
            }
            else {
                foreach ($sq in $_) {
                    if ($sq.position -in $options) { $backgroundColor = 'white' }
                    else { $backgroundColor = 'red' }

                    write-host '   ' -NoNewline
                    write-host " $($sq.output()) " -BackgroundColor $backgroundColor -ForegroundColor black -NoNewline
                }
            }
            write-host
        }

        $team0 = "$('○' * $this.player0.discardedPieces())$(' ' * (8-$this.player0.discardedPieces()))"
        $team1 = "$(' ' * (8-$this.player1.discardedPieces()))$('●' * $this.player1.discardedPieces())"

        write-host "  $team0        $team1"
    }

    [void] printNumbers() {
        $counter = 0
        write-host "   0  1  2  3  4  5  6  7"
        $this.toRows() | foreach-object {
            write-host "$counter " -NoNewline
            $counter++
            if ([math]::floor($_[0].id / 4) % 2 -eq 0) {
                foreach ($sq in $_) {
                    write-host $sq.position -BackgroundColor red -ForegroundColor black -NoNewline
                    write-host '   ' -NoNewline
                }
            }
            else {
                foreach ($sq in $_) {
                    write-host '   ' -NoNewline
                    write-host $sq.position -BackgroundColor red -ForegroundColor black -NoNewline
                }
            }
            write-host
        }
    }

    [void] printDetails() {
        $list = @()
        $this.toList() | foreach-object {
            $list += [PSCustomObject]@{
                position    = $_.position
                topLeft     = $_.topLeft.position
                topRight    = $_.topRight.position
                bottomLeft  = $_.bottomLeft.position
                bottomright = $_.bottomRight.position
            }
        }
        write-host $list
        $list | format-table
    }

    [square[]] toList() {
        $list = @()
        $square = $this.primary

        while ($square.right) {
            $list += $square
            $square = $square.right
        }

        return $list
    }

    [square[][]] toRows() {
        $list = @(@(), @(), @(), @(), @(), @(), @(), @())

        $this.toList() | foreach-object {
            $list[[math]::floor($_.id / 4)] += $_
        }
        return $list

    }

    [square] getSquare([int] $id) {
        return $this.toList() | where-object { $_.id -eq $id }
    }

    [square] getSquare([string] $position) {
        return $this.toList() | where-object { $_.position -eq $position }
    }

    [piece] getPiece([int] $id) {
        return $this.pieces[$id]
    }

    [piece] getPiece([string] $position) {
        return $this.pieces | where-object { $_.square.position -eq $position }
    }

    [boolean] movePiece([string]$from, [string] $to) {
        write-host
        $movePiece = $this.getPiece($from).move($to)
        if ($movePiece) { write-host 'Move Successful' }
        else { write-host 'Invalid Move' }
        start-sleep 1
        return $movePiece
    }

    [void] playGameLocalType() {
        $position = $false
        $currentPlayer = $this.player0
        $nextPlayer = $this.player1
        while ($this.player0.discardedPieces() -lt 8 -or $this.player1.discardedPieces() -lt 8) {
            clear-host
            write-host "Checkers`r`n"
            # write-host $position
            $this.print($position)
            # $currentPlayer.print()
            write-host
            $tempInput = read-host "Player $($currentPlayer.team)"
            $position = $false
            $status = $false
            switch -regex ($tempInput) {
                '^move (?<from>[0-7]\.[0-7]) to (?<to>[0-7]\.[0-7])$' {
                    $status = $currentPlayer.movePiece($Matches.from, $Matches.to)
                }
                '^(?<from>[0-7]\.[0-7]) to (?<to>[0-7]\.[0-7])$' {
                    $status = $currentPlayer.movePiece($Matches.from, $Matches.to)
                }
                '^(?<from>[0-7]\.[0-7]) (?<to>[0-7]\.[0-7])$' {
                    $status = $currentPlayer.movePiece($Matches.from, $Matches.to)
                }
                '^(?<position>[0-7]\.[0-7])$' {
                    $position = $Matches.position
                }
                'exit' { exit }
                Default { $status = $false }
            }
            if ($status) {
                $temp = $currentPlayer
                $currentPlayer = $nextPlayer
                $nextPlayer = $temp
            }
        }

        clear-host
        write-host "Checkers`r`n"
        $this.print()

        $winner = & {
            if ($this.player0.discardedPieces() -eq 0) { $this.player0 }
            else { $this.player1 }
        }

        "Player $($winner.team) wins!"

    }

    [void] playGameLocalArrows() {
        $currentPlayer = $this.player0
        $nextPlayer = $this.player1

        while ($this.player0.discardedPieces() -lt 8 -or $this.player1.discardedPieces() -lt 8) {
            $currentPlayerPieces = $currentPlayer.activePieces()
            $currentPiece = -1

            $turnLooper = $true
            while ($turnLooper) {
                clear-host
                if ($currentPiece -eq $currentPlayerPieces.count - 1) { $currentPiece = 0 }
                else { $currentPiece++ }

                $this.print($currentPlayerPieces[$currentPiece].square.position)
                $tempInput = $this.host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")

                
            }

            

            clear-host
            write-host "Checkers`r`n"
            # $this.print($position)
            # $currentPlayer.print()
            write-host
            $tempInput = read-host "Player $($currentPlayer.team)"
            $position = $false
            $status = $false
            switch -regex ($tempInput) {
                '^move (?<from>[0-7]\.[0-7]) to (?<to>[0-7]\.[0-7])$' {
                    $status = $currentPlayer.movePiece($Matches.from, $Matches.to)
                }
                '^(?<from>[0-7]\.[0-7]) to (?<to>[0-7]\.[0-7])$' {
                    $status = $currentPlayer.movePiece($Matches.from, $Matches.to)
                }
                '^(?<from>[0-7]\.[0-7]) (?<to>[0-7]\.[0-7])$' {
                    $status = $currentPlayer.movePiece($Matches.from, $Matches.to)
                }
                '^(?<position>[0-7]\.[0-7])$' {
                    $position = $Matches.position
                }
                'exit' { exit }
                Default { $status = $false }
            }
            if ($status) {
                $temp = $currentPlayer
                $currentPlayer = $nextPlayer
                $nextPlayer = $temp
            }
        }
    }

}

$board = [board]::new($host)

$board.playGameLocalType()