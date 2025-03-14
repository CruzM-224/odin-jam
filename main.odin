package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"

main :: proc() {

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

	timePassed : f32 = 0
	timeToDelete : f32 = 0.01

    windowWidth : i32 : 800
    windowHeight : i32 : 600

	tiles : Rectangle : {50, 50}

	rows, columns : i32 : windowHeight/tiles.height, windowWidth/tiles.width
	row, column : i32

	// Empty: 0, Begin: 1, End: 2, Path: 3, Obstacle: 4
	Values :: enum {Empty, Begin, End, Path, Obstacle}

	MapBool :: [rows][columns]bool
	MapInt :: [rows][columns]int
	
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

	objectsMap : MapInt
	
	// Finish 0 - 2, Begin 9 - 11
	getFinishPos :: proc() -> (int, int) {
		finishRowRange : [3]int = {0, 1, 2}
		finishColumnRange : [16]int = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
		
		finishRow := int(rand.choice(finishRowRange[:]))
		finishColumn := int(rand.choice(finishColumnRange[:]))

		return finishRow, finishColumn
	}

	finishPos : tilePos

	getBeginPos :: proc() -> (int, int) {
		beginRowRange : [2]int = {10, 11}
		beginColumnRange : [16]int = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
		
		beginRow := int(rand.choice(beginRowRange[:]))
		beginColumn := int(rand.choice(beginColumnRange[:]))

		return beginRow, beginColumn
	}

	beginPos : tilePos

	getObstaclePos :: proc() -> (int, int) {
		obstacleRowRange : [12]int = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
		obstacleColumnRange : [16]int = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
		
		obstacleRow := int(rand.choice(obstacleRowRange[:]))
		obstacleColumn := int(rand.choice(obstacleColumnRange[:]))

		return obstacleRow, obstacleColumn
	}

	setInitialMap :: proc() -> (MapInt, tilePos, tilePos){
		objectsMap : MapInt = getObjectsMapClean()
		beginPos : tilePos
		finishPos : tilePos
		beginPos.row, beginPos.column = getBeginPos()
		finishPos.row, finishPos.column = getFinishPos()
		objectsMap[beginPos.row][beginPos.column], objectsMap[finishPos.row][finishPos.column] = int(Values.Begin), int(Values.End)
		
		qtyObstacles := rand.int_max(32)
		for qtyObstacles > 0 {
			obstaclePos : tilePos
			obstaclePos.row, obstaclePos.column = getObstaclePos()
			if(objectsMap[obstaclePos.row][obstaclePos.column] == int(Values.Empty)){
				objectsMap[obstaclePos.row][obstaclePos.column] = int(Values.Obstacle)
				qtyObstacles -= 1
			}
		}

		return objectsMap, beginPos, finishPos
	}

	objectsMap, beginPos, finishPos = setInitialMap()

	rl.InitWindow(windowWidth, windowHeight, "Game")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		deltaTime := rl.GetFrameTime()
		
		rl.BeginDrawing()
		rl.ClearBackground(colorMap)

		for i : i32 = 0; i < windowHeight; i += tiles.height {
			for j : i32 = 0; j < windowWidth; j += tiles.width {
				if(objectsMap[i/tiles.height][j/tiles.width] == int(Values.Path)){
					rl.DrawRectangle(j, i, tiles.width, tiles.height, colorPath)
				}else{
					if(objectsMap[i/tiles.height][j/tiles.width] == int(Values.Obstacle)){
						rl.DrawRectangle(j, i, tiles.width, tiles.height, rl.GREEN)
					}
				}
				rl.DrawRectangleLines(j, i, tiles.width, tiles.height, rl.BLACK)
			}
		}

		if(rl.IsMouseButtonDown(rl.MouseButton.RIGHT)){
			temp := rl.GetMousePosition()
			tempPoint : Point = {x=i32(temp[0]), y=i32(temp[1])}

			if(startPos.x != -1){
				endPos = startPos
			}else{
				endPos = tempPoint
			}

			startPos = tempPoint

			fmt.println(startPos)
			fmt.println(endPos)
			append(&drawnLines, Line{startPos, endPos})
		}else{
			timePassed += deltaTime
			if(timePassed >= timeToDelete){
				timePassed = 0
				if(len(drawnLines) > 0){
					row, column = drawnLines[0].startPos.y/tiles.height, drawnLines[0].startPos.x/tiles.width
					if(objectsMap[row][column] == int(Values.Empty)){
						objectsMap[row][column] = int(Values.Path)
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

		if(rl.IsKeyPressed(rl.KeyboardKey.R)){
			objectsMap, beginPos, finishPos = setInitialMap()
		}
		if(rl.IsMouseButtonPressed(rl.MouseButton.LEFT)){
			temp := rl.GetMousePosition()
			tempPoint : Point = {x=i32(temp[0]), y=i32(temp[1])}
			row, column = tempPoint.y/tiles.height, tempPoint.x/tiles.width
			if(objectsMap[row][column] == int(Values.Empty)){
				objectsMap[row][column] = int(Values.Obstacle)
			}
		}

		rl.DrawRectangle(i32(finishPos.column) * tiles.width, i32(finishPos.row) * tiles.height, tiles.width, tiles.height, rl.BLACK)
		rl.DrawRectangle(i32(beginPos.column) * tiles.width, i32(beginPos.row) * tiles.height, tiles.width, tiles.height, rl.BLACK)

		rl.EndDrawing()
		fmt.println(objectsMap)
	}
}
