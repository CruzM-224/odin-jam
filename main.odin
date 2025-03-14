package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"

main :: proc() {

	textureCharacter : rl.Texture2D
	textureTree : rl.Texture2D

	Point :: struct {
		x, y : i32
	}

	tilePos :: struct {
		row, column : int
	}

	Line :: struct {
		startPos, endPos : Point
	}

	Rectangle :: struct {
		width, height : i32
	}

	// palette
	colorPath : rl.Color = {242, 235, 204, 255}
	colorMap : rl.Color = {205, 229, 217, 255}

	startPos : Point = {-1, -1}
	endPos : Point

	drawnLines : [dynamic]Line

	obstaclesCap : int = 32

	obstaclesPos : [dynamic]tilePos

	characterPosArray : [dynamic]tilePos

	pathArray : [dynamic]tilePos

	score : int
	requireScore : int

	timePassed : f32 = 0
	timeToDelete : f32 = 0.01
	cont : f32 = 0
	cont2 : f32 = 0
	timeToWalk : f32 = 0.5
	delay : f32 = 0.5

    windowWidth : i32 : 800
    windowHeight : i32 : 600

	walk : bool = false
	obstaclesInit : bool = false
	travelEnd : bool = false

	tiles : Rectangle : {50, 50}
	character : Rectangle : {30, 40}
	tree : Rectangle : {30, 60}

	rows, columns : i32 : windowHeight/tiles.height, windowWidth/tiles.width
	row, column : i32

	// Empty: 0, Begin: 1, End: 2, Path: 3, Obstacle: 4
	Values :: enum {Empty, Begin, End, Path, Obstacle}
	
	alignment :: enum {
        vertical,
        horizontal,
        center
    }

	MapBool :: [rows][columns]bool
	MapInt :: [rows][columns]int
	
	beginPos : tilePos
	finishPos : tilePos
	objectsMap : MapInt
	objectsMapBeginCopy : MapInt
	characterPos : tilePos
	qtyObstacles : int

	getObjectsMapClean :: proc() -> MapInt {
		objectsMap : MapInt
		objectsMap[0]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		objectsMap[1]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		objectsMap[2]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		objectsMap[3]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		objectsMap[4]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		objectsMap[5]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		objectsMap[6]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		objectsMap[7]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		objectsMap[8]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		objectsMap[9]  = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		objectsMap[11] = [columns]int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

		return objectsMap
	}
	
	// Finish 0 - 2, Begin 9 - 11
	getFinishPos :: proc() -> (int, int) {
		finishRowRange : [3]int = {0, 1, 2}
		finishColumnRange : [16]int = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
		
		finishRow := int(rand.choice(finishRowRange[:]))
		finishColumn := int(rand.choice(finishColumnRange[:]))

		return finishRow, finishColumn
	}


	getBeginPos :: proc() -> (int, int) {
		beginRowRange : [2]int = {10, 11}
		beginColumnRange : [16]int = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
		
		beginRow := int(rand.choice(beginRowRange[:]))
		beginColumn := int(rand.choice(beginColumnRange[:]))

		return beginRow, beginColumn
	}

	

	getObstaclePos :: proc() -> (int, int) {
		obstacleRowRange : [12]int = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
		obstacleColumnRange : [16]int = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
		
		obstacleRow := int(rand.choice(obstacleRowRange[:]))
		obstacleColumn := int(rand.choice(obstacleColumnRange[:]))

		return obstacleRow, obstacleColumn
	}

	setInitialMap :: proc() -> (MapInt, tilePos, tilePos, int){
		objectsMap : MapInt = getObjectsMapClean()
		beginPos : tilePos
		finishPos : tilePos
		beginPos.row, beginPos.column = getBeginPos()
		finishPos.row, finishPos.column = getFinishPos()
		objectsMap[beginPos.row][beginPos.column], objectsMap[finishPos.row][finishPos.column] = int(Values.Begin), int(Values.End)
		
		qtyObstacles := rand.int_max(32 /* obstacleCap */)
		qtyObstaclesBegin := qtyObstacles
		for qtyObstacles > 0 {
			obstaclePos : tilePos
			obstaclePos.row, obstaclePos.column = getObstaclePos()
			if(objectsMap[obstaclePos.row][obstaclePos.column] == int(Values.Empty)){
				objectsMap[obstaclePos.row][obstaclePos.column] = int(Values.Obstacle)
				qtyObstacles -= 1
			}
		}

		return objectsMap, beginPos, finishPos, qtyObstaclesBegin
	}

	objectsMap, beginPos, finishPos, qtyObstacles = setInitialMap()
	objectsMapBeginCopy = objectsMap
	characterPos = beginPos

	drawTextAligned :: proc (text: cstring, fontSize: i32, posX : i32 = 0, posY : i32 = 0, centerAlign : alignment, windowWidth, windowHeight : i32) {
        size := rl.MeasureText(text, fontSize)
        switch centerAlign {
        case .vertical:
            rl.DrawText(text, posX, (windowHeight - fontSize)/2, fontSize, rl.BLACK)
        case .horizontal:
            rl.DrawText(text, (windowWidth - size)/2, posY, fontSize, rl.BLACK)
        case .center:
            rl.DrawText(text, (windowWidth - size)/2, (windowHeight - fontSize)/2, fontSize, rl.BLACK)
        case:   fmt.println("Incorrect orientation")
        }
    }

	rl.InitWindow(windowWidth, windowHeight, "Game")

	textureCharacter = rl.LoadTexture("sprites/character.png")
	textureTree = rl.LoadTexture("sprites/tree.png")

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		deltaTime := rl.GetFrameTime()
		
		rl.BeginDrawing()
		rl.ClearBackground(colorMap)

		if cont2 < delay {
			for i : i32 = 0; i < windowHeight; i += tiles.height {
				for j : i32 = 0; j < windowWidth; j += tiles.width {
					if(objectsMap[i/tiles.height][j/tiles.width] == int(Values.Path)){
						rl.DrawRectangle(j, i, tiles.width, tiles.height, colorPath)
					}else{
						if(objectsMap[i/tiles.height][j/tiles.width] == int(Values.Obstacle)){
							if !obstaclesInit {
								append(&obstaclesPos, tilePos{int(i/tiles.height), int(j/tiles.width)})
							}
						}
					}
					rl.DrawRectangleLines(j, i, tiles.width, tiles.height, rl.BLACK)
				}
			}
			obstaclesInit = true

			if(rl.IsMouseButtonDown(rl.MouseButton.RIGHT)){
				temp := rl.GetMousePosition()
				tempPoint : Point = {x=i32(temp[0]), y=i32(temp[1])}

				if(startPos.x != -1){
					endPos = startPos
				}else{
					endPos = tempPoint
				}

				startPos = tempPoint

				append(&drawnLines, Line{startPos, endPos})
			}else{
				timePassed += deltaTime
				if(timePassed >= timeToDelete){
					timePassed = 0
					if(len(drawnLines) > 0){
						row, column = drawnLines[0].startPos.y/tiles.height, drawnLines[0].startPos.x/tiles.width
						if(objectsMap[row][column] == int(Values.Empty)){
							objectsMap[row][column] = int(Values.Path)
							append(&pathArray, tilePos{int(row), int(column)})
						}
						ordered_remove(&drawnLines, 0)
					}else{
						startPos = {-1, -1}
					}
				}
			}
			
			for value in drawnLines {
				rl.DrawLine(value.startPos.x, value.startPos.y, value.endPos.x, value.endPos.y, rl.BLACK)
			}
			

			if(rl.IsMouseButtonPressed(rl.MouseButton.LEFT)){
				temp := rl.GetMousePosition()
				tempPoint : Point = {x=i32(temp[0]), y=i32(temp[1])}
				row, column = tempPoint.y/tiles.height, tempPoint.x/tiles.width
				if(objectsMap[row][column] == int(Values.Empty)){
					objectsMap[row][column] = int(Values.Obstacle)
					append(&obstaclesPos, tilePos{int(row), int(column)})
					fmt.println("Arreglo de obstaculos")
					fmt.println(obstaclesPos)
				}
			}

			if(rl.IsKeyPressed(rl.KeyboardKey.L)){
				fmt.println(objectsMap)
			}

			rl.DrawRectangle(i32(finishPos.column) * tiles.width, i32(finishPos.row) * tiles.height, tiles.width, tiles.height, rl.BLACK)
			rl.DrawRectangle(i32(beginPos.column) * tiles.width, i32(beginPos.row) * tiles.height, tiles.width, tiles.height, rl.BLACK)

			rl.DrawTexture(textureCharacter, (i32(characterPos.column) * tiles.width) + (tiles.width - character.width)/2, (i32(characterPos.row) * tiles.height) + (tiles.height - character.height)/2, rl.WHITE)
			
			for i := 0; i < int(rows); i += 1 {
				for obstacle in obstaclesPos {
					if(obstacle.row == i){
						rl.DrawTexture(textureTree, (i32(obstacle.column) * tiles.width) + (tiles.width - tree.width)/2, (i32(obstacle.row) * tiles.height) + (tiles.height - tree.height), rl.WHITE)
					}
				}
			}

			if(rl.IsKeyPressed(rl.KeyboardKey.SPACE) && len(drawnLines) == 0){
				walk = !walk
			}

			if walk {
				cont += deltaTime
				// Character movement logic
				if((cont >= timeToWalk || characterPos == beginPos) && characterPos.column > 0){
					if characterPos != beginPos {
						append(&characterPosArray, characterPos)
					}
					characterPos.column -= 1
					if(characterPos.column == 0){
						append(&characterPosArray, characterPos)
						fmt.println("Hola")
						travelEnd = true
						walk = false
						cont2 = 0
					}
					cont = 0
					fmt.println(characterPosArray)
				}
			}
		}
		if(travelEnd){
			cont2 += deltaTime
		}
		if(cont2 >= delay){
			score = 0
			if len(characterPosArray) > len(pathArray) {
				for position in characterPosArray {
					for pathPosition in pathArray {
						if pathPosition == position {
							score += 1
						}
					}
				}
				requireScore = len(characterPosArray)
			}else{
				for position in characterPosArray {
					for pathPosition in pathArray {
						if pathPosition == position {
							score += 1
						}
					}
				}
				requireScore = len(pathArray)
			}
			rl.DrawRectangle(100, 100, 600, 400, rl.WHITE)
			drawTextAligned(rl.TextFormat("%d / 100", int(f32(score)/f32(requireScore) * 100)), 60, 0, 0, alignment.center, windowWidth, windowHeight)
		}

		// change level
		if(rl.IsKeyPressed(rl.KeyboardKey.C)){
			objectsMap, beginPos, finishPos, qtyObstacles = setInitialMap()
			objectsMapBeginCopy = objectsMap
			characterPos = beginPos
			obstaclesInit = false
			for len(obstaclesPos) > 0 {
				pop(&obstaclesPos)
			}
			for len(characterPosArray) > 0 {
				pop(&characterPosArray)
			}
			for len(pathArray) > 0 {
				pop(&pathArray)
			}
			travelEnd = false
			walk = false
			cont2 = 0
		}

		// retry level
		if(rl.IsKeyPressed(rl.KeyboardKey.R)){
			objectsMap = objectsMapBeginCopy
			characterPos = beginPos
			fmt.println(qtyObstacles)
			for len(obstaclesPos) > qtyObstacles {
				pop(&obstaclesPos)
			}
			for len(characterPosArray) > 0 {
				pop(&characterPosArray)
			}
			for len(pathArray) > 0 {
				pop(&pathArray)
			}
			travelEnd = false
			walk = false
			cont2 = 0
		}

		rl.EndDrawing()

		// fmt.println(objectsMap)
	}
}
