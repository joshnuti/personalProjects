$host.ui.RawUI.WindowTitle = “Checkers”

$global:logPath = "$PSScriptRoot\checkers log.txt"
out-file $global:logPath

$global:debug = $true

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
    [int]$numMoves

    piece(
        [int]$team,
        [square]$square,
        [int]$pieceID
    ) {
        $this.team = $team
        $this.square = $square
        $this.id = $pieceID
        
        $this.king = $false
        $this.numMoves = 0
    }

    [boolean] onBoard() {
        if ($this.square) { return $true }
        else { return $false }
    }

    [move[]] getMoves() {
        $moves = @()



        return $moves
    }

    [object[]] getOptions() {
        # if ($this.team -eq 0 -or $this.king) { $down = $true }
        # else { $down = $false }
        
        # if ($this.team -eq 1 -or $this.king) { $up = $true }
        # else { $up = $false }

        $options = @()

        $options += $this.square.getJumps($this)

        # if direction has piece & direction piece team != this team & not direction.direction piece & can move up/down
        # if ($this.square.topLeft.piece -and $this.square.topLeft.piece.team -ne $this.team -and !$this.square.topLeft.topLeft.piece -and $up) {
        #     $options += [PSCustomObject]@{square = $this.square.topLeft.topLeft; piece = $this.square.topLeft.piece }
        # }
        # if ($this.square.topRight.piece -and $this.square.topRight.piece.team -ne $this.team -and !$this.square.topRight.topRight.piece -and $up) {
        #     $options += [PSCustomObject]@{square = $this.square.topRight.topRight; piece = $this.square.topRight.piece }
        # }
        # if ($this.square.bottomLeft.piece -and $this.square.bottomLeft.piece.team -ne $this.team -and !$this.square.bottomLeft.bottomLeft.piece -and $down) {
        #     $options += [PSCustomObject]@{square = $this.square.bottomLeft.bottomLeft; piece = $this.square.bottomLeft.piece } 
        # }
        # if ($this.square.bottomRight.piece -and $this.square.bottomRight.piece.team -ne $this.team -and !$this.square.bottomRight.bottomRight.piece -and $down) {
        #     $options += [PSCustomObject]@{square = $this.square.bottomRight.bottomRight; piece = $this.square.bottomRight.piece }
        # }

        $options += $this.square.getMoves($this)

        # if direction is not null & not direction piece & can move up/down
        # if ($null -ne $this.square.topLeft -and !$this.square.topLeft.piece -and $up) {
        #     $options += [PSCustomObject]@{square = $this.square.topLeft; piece = $null }
        # }
        # if ($null -ne $this.square.topRight -and !$this.square.topRight.piece -and $up) {
        #     $options += [PSCustomObject]@{square = $this.square.topRight; piece = $null }
        # }
        # if ($null -ne $this.square.bottomLeft -and !$this.square.bottomLeft.piece -and $down) {
        #     $options += [PSCustomObject]@{square = $this.square.bottomLeft; piece = $null }
        # }
        # if ($null -ne $this.square.bottomRight -and !$this.square.bottomRight.piece -and $down) {
        #     $options += [PSCustomObject]@{square = $this.square.bottomRight; piece = $null }
        # }

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

            $this.numMoves++
            return $true
        }
        else {
            return $false
        }
    }

    [void] printDetails() {
        $options = $this.getOptions().square.position

        write-host "Team $($this.team)"
        write-host "King: $($this.king)"
        write-host "OnBoard: $($this.onBoard())"
        write-host "Position: $($this.square.position)"
        write-host "Options $($options)"        
    }

    [string] getDetails() {
        $options = $this.getOptions()

        $opts = $options.square.position
        $k = & { if ($this.king) { 'King ' }else { 'Piece' } }
        $position = & { if ($this.onboard()) { $this.square.position }else { '   ' } }

        $nextMoves = $options.nextMove.square.position

        return "$($this.team) $($position) $k ($opts) [$nextMoves]"
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

    [object[]] getJumps([piece] $piece) {
        # write-host $piece.id $piece.team
        $directions = @()

        if ($piece.team -eq 0 -or $piece.king) { $directions += @('bottomLeft', 'bottomRight') }
        if ($piece.team -eq 1 -or $piece.king) { $directions += @('topLeft', 'topRight') }

        # write-host $this.position $directions

        $options = @()
        
        $directions | foreach-object {
            if ($this.$_.piece -and $this.$_.piece.team -ne $piece.team -and !$this.$_.$_.piece) {
                if ($this.$_.$_) {
                    # write-host "recursing to $_ $($this.$_.$_.position)"
                    $options += [PSCustomObject]@{square = $this.$_.$_; piece = $this.$_.piece; nextMove = $this.$_.$_.getJumps($piece) }
                }
                else {
                    $options += [PSCustomObject]@{square = $this.$_.$_; piece = $this.$_.piece; nextMove = $null }
                }
            }
        }

        return $options
    }

    [object[]] getMoves([piece] $piece) {
        $directions = @()

        if ($piece.team -eq 0 -or $piece.king) { $directions += @('bottomLeft', 'bottomRight') }
        if ($piece.team -eq 1 -or $piece.king) { $directions += @('topLeft', 'topRight') }

        $options = @()

        $directions | foreach-object {
            if ($this.$_ -and !$this.$_.piece) {
                $options += [PSCustomObject]@{square = $this.$_; piece = $null; nextMove = $null }
            }
        }

        return $options
    }

    [move[]] getMoves2([piece] $piece) {
        $directions = @()
        if ($piece.team -eq 0 -or $piece.king) { $directions += @('bottomLeft', 'bottomRight') }
        if ($piece.team -eq 1 -or $piece.king) { $directions += @('topLeft', 'topRight') }

        $moves = @()

        $directions | foreach-object {
            if ($this.$_ -and !$this.$_.piece) {
                $moves += [move]::new($piece, $this, $this.$_, $null)
            }
        }

        return $moves
    }

}

class player {
    [int]$team
    [piece[]]$pieces
    [boolean]$cpu
    [board]$board
    [player]$otherPlayer
    [int] $turns

    player(
        [int]$team,
        [board]$board
    ) {
        $this.team = $team
        $this.board = $board
        $this.pieces = @()
        $this.turns = 0
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
}

class move {
    [player] $player
    [piece] $piece
    [piece] $jumpedPiece
    [square] $from
    [square] $to
    [move]$previous
    [move]$next

    move (
        [player] $player,
        [piece] $piece,
        [square] $from,
        [square] $to,
        [move] $previous
    ) {
        if (!($null -eq $player)) {
            $this.player = $player
            $this.piece = $piece
            $this.from = $from
            $this.to = $to
            $this.previous = $previous
        }
    }

    move (
        [piece] $piece, 
        [square] $from, 
        [square] $to, 
        [piece] $jumpedPiece
    ) {
        $this.piece = $piece
        $this.from = $from
        $this.to = $to
        $this.jumpedPiece = $jumpedPiece
    }

    [string] getSentence() {
        return "Player $($this.piece.team) moved Piece $($this.piece.id) from $($this.from) to $($this.to)"
    }

    [void] printDetails() {
        write-host $this.getSentence()
    }
}

class board {
    hidden [square] $primary
    hidden [piece[]] $pieces
    hidden [player] $player0
    hidden [player] $player1
    [move] $firstMove #= [move]::new($null, $null, $null, $null, $null)
    hidden [move] $lastMove
    hidden $host

    board($hostValue) {
        $this.host = $hostValue

        $this.player0 = [player]::new(0, $this)
        $this.player1 = [player]::new(1, $this)

        $this.player0.otherPlayer = $this.player1
        $this.player1.otherPLayer = $this.player0

        $this.firstMove = [move]::new($null, $null, $null, $null, $null)
        $this.lastMove = $this.firstMove

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

    [player] winner() {
        if (($this.player0.pieces | where-object { !$_.onBoard() }).count -eq 0 ) { return $this.player0 }
        if (($this.player1.pieces | where-object { !$_.onBoard() }).count -eq 0 ) { return $this.player1 }
        else { return $null }
    }

    [void] print($position, $optionPosition) {
        # clear-host

        if ($position) {
            $piece = $this.getPiece($position)
            $pieceOptions = $piece.getOptions()

            $options = @()

            $options += $pieceOptions.square.position
            $options += $position

            $nextMove = $pieceOptions.nextMove
            while ($nextMove) {
                write-host 'there is a next move'
                $options += $nextMove.square.position
                $nextMove = $nextMove.nextMove
            }

            # if ($options) {
            #     if ($options.getType().Name -eq 'String') {
            #         $options = @($options, $position)
            #     }
            #     else {
            #         $options += $position
            #     }
            # }
            # else {
            #     $options = @($position)
            # }


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
                    if ( $sq.position -eq $optionPosition) { $backgroundColor = 'cyan' }
                    elseif ($sq.position -in $options) { $backgroundColor = 'white' }
                    else { $backgroundColor = 'red' }

                    write-host " $($sq.output()) " -BackgroundColor $backgroundColor -ForegroundColor black -NoNewline
                    write-host '   ' -NoNewline
                }
            }
            else {
                foreach ($sq in $_) {
                    if ( $sq.position -eq $optionPosition) { $backgroundColor = 'cyan' }
                    elseif ($sq.position -in $options) { $backgroundColor = 'white' }
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

    [move[]] getMoves() {
        $moves = @()

        $currentMove = $this.firstMove.next
        while ($currentMove) {
            $moves += $currentMove
            $currentMove = $currentMove.next
        }

        return $moves
    }

    [square] getSquare([int] $id) {
        return $this.toList() | where-object { $_.id -eq $id }
    }

    [square] getSquare([string] $position) {
        return $this.toList() | where-object { $_.position -eq $position }
    }

    [piece] getPiece([int] $id) {
        return $this.pieces | where-object { $_.id = $id }
    }

    [piece] getPiece([string] $position) {
        return $this.pieces | where-object { $_.square.position -eq $position }
    }

    [boolean] movePiece([string]$from, [string] $to) {
        $piece = $this.getPiece($from)

        $movePiece = $piece.move($to)
        
        $player = "player$($piece.team)"

        $currentMove = $this.lastMove
        $currentMove.next = [move]::new($this.$player, $piece, $from, $to, $currentMove)
        $currentMove.next.previous = $currentMove
        $this.lastMove = $currentMove.next
        
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

        $this.movePiece('1.1', '2.2')
        $this.movePiece('2.2', '3.3')
        $this.movePiece('6.2', '5.3')
        $this.movePiece('5.3', '4.4')
        $this.movePiece('6.6', '5.7')
        $this.movePiece('7.7', '6.6')

        while ($this.player0.discardedPieces() -lt 8 -or $this.player1.discardedPieces() -lt 8) {
            $currentPlayer.turns += 1
            $currentPlayerPieces = $currentPlayer.activePieces()  | sort-object { [int]$_.square.position }
            out-log "Player $($currentPlayer.team) Turn $($currentPLayer.turns)"
            $currentPiece = 0

            $currentPieceOptions = $false
            $currentPieceOption = $false

            $moves = 0

            $turnLooper = $true
            while ($turnLooper) {
                $moves++
                clear-host
                write-host "Checkers`r`n"
                write-host "Current Player: Player $($currentPlayer.team)`r`n"

                if ($currentPieceOptions) {
                    $currentPieceOptionPosition = $currentPieceOptions[$currentPieceOption].square.position
                }
                else {
                    $currentPieceOptionPosition = $false
                }
                
                $this.print($currentPlayerPieces[$currentPiece].square.position, $currentPieceOptionPosition)
                out-log "  $moves `$board.print('$($currentPlayerPieces[$currentPiece].square.position)', '$($currentPieceOptionPosition)')"

                if ($global:debug) {
                    $currentPlayer.pieces | foreach-object {
                        write-host $_.getDetails()
                    }
                }

                $keyInput = ($this.host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")).virtualkeycode
                out-log "  $moves KeyInput = $($keyInput.virtualkeycode)"

                # next - w (87) and d (68) and -> (39) and ^ (38)
                if ($keyInput -in (87, 68, 39, 38)) {
                    if (!$currentPieceOptions) {
                        if ($currentPiece + 1 -eq $currentPlayerPieces.count) { $currentPiece = 0 }
                        else { $currentPiece++ }
                    }
                    else {
                        if ($currentPieceOption + 1 -eq $currentPieceOptions.count) { $currentPieceOption = 0 }
                        else { $currentPieceOption++ }
                    }
                    
                }
                # prev - a (65) and s (83) and <- (37) and *down arrow* (40)
                elseif ($keyInput -in (65, 83, 37, 40)) {
                    if (!$currentPieceOptions) {
                        if ($currentPiece -eq 0) { $currentPiece = $currentPlayerPieces.count - 1 }
                        else { $currentPiece-- }
                    }
                    else {
                        if ($currentPieceOption -eq 0) { $currentPieceOption = $currentPieceOptions.count - 1 }
                        else { $currentPieceOption-- }
                    }
                }
                # select piece - Return (13)
                elseif ($keyInput -eq 13) {
                    if (!$currentPieceOptions) {
                        $currentPieceOptions = $currentPlayerPieces[$currentPiece].getOptions()
                        $currentPieceOption = 0
                    }
                    else {
                        $status = $this.movePiece($currentPlayerPieces[$currentPiece].square.position, $currentPieceOptions[$currentPieceOption].square.position)
                        if ($status) {
                            $turnLooper = $false
                        }
                    }
                }
                # deselect piece - b (66)
                elseif ($keyInput -eq 66) {
                    $currentPieceOptions = $false
                    $currentPieceOption = 0
                    
                }
                # exit - e (69)
                elseif ($keyInput -eq 69) {
                    write-host "`r`nAre you sure you want to exit? (y/n)" -NoNewline
                    $keyInput = ($this.host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")).virtualkeycode
                    if ($keyinput -eq 89) { write-host; exit }
                }
            }

            $currentPlayer = $currentPlayer.otherPlayer
        }
    }

}

$board = [board]::new($host)

$board.playGameLocalArrows()