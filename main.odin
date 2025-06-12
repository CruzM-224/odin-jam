package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:math"

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

	option :: struct {
		pos : tilePos,
		movements, weight : int
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

	calculatedPath : [dynamic]tilePos

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

	pathCalculate :: proc (obstaclesMap: MapInt, beginPos: tilePos, finishPos: tilePos) -> ([dynamic]tilePos) {
		fmt.println("Iniciando cálculo de ruta...")
		
		// Crear un arreglo para el resultado
		result: [dynamic]tilePos
		
		// Matriz para marcar las celdas visitadas
		visited: [12][16]bool
		
		// Almacenar todos los nodos explorados y sus padres
		Node :: struct {
			pos: tilePos,
			parent_index: int,  // Índice del padre en nodes
		}
		
		nodes: [dynamic]Node
		
		// Cola para BFS
		queue: [dynamic]int  // Índices en nodes
		
		// Agregar el nodo inicial
		append(&nodes, Node{beginPos, -1})
		append(&queue, 0)  // Índice del nodo inicial en nodes
		
		found := false
		target_index := -1
		
		// Direcciones: arriba, derecha, abajo, izquierda
		directions := [4]tilePos{{-1, 0}, {0, 1}, {1, 0}, {0, -1}}
		
		fmt.println("Comenzando búsqueda BFS...")
		
		// BFS
		for len(queue) > 0 {
			// Obtener el índice del nodo actual
			current_index := queue[0]
			current_node := nodes[current_index]
			ordered_remove(&queue, 0)
			
			// Si ya visitamos esta posición, continuar
			if visited[current_node.pos.row][current_node.pos.column] {
				continue
			}
			
			// Marcar como visitada
			visited[current_node.pos.row][current_node.pos.column] = true
			
			// Si es el destino, terminar
			if current_node.pos == finishPos {
				found = true
				target_index = current_index
				fmt.println("¡Destino encontrado! Índice:", target_index)
				break
			}
			
			// Explorar vecinos
			for dir in directions {
				next_pos := tilePos{
					row = current_node.pos.row + dir.row,
					column = current_node.pos.column + dir.column,
				}
				
				// Verificar límites y obstáculos
				if next_pos.row < 0 || next_pos.row >= 12 ||
				   next_pos.column < 0 || next_pos.column >= 16 ||
				   obstaclesMap[next_pos.row][next_pos.column] == 4 ||
				   visited[next_pos.row][next_pos.column] {
					continue
				}
				
				// Crear nuevo nodo
				new_node_index := len(nodes)
				append(&nodes, Node{next_pos, current_index})
				append(&queue, new_node_index)
			}
		}
		
		// Si no se encontró camino
		if !found {
			fmt.println("No se pudo encontrar un camino al destino.")
			return result
		}
		
		// Reconstruir el camino
		fmt.println("Reconstruyendo camino...")
		
		// Construir el camino desde el destino hasta el inicio
		path: [dynamic]tilePos
		
		// Comenzar desde el destino y retroceder
		current_index := target_index
		for current_index >= 0 {
			append(&path, nodes[current_index].pos)
			current_index = nodes[current_index].parent_index
		}
		
		// Invertir el camino para obtener el orden correcto (excluyendo la posición inicial)
		for i := len(path) - 2; i >= 0; i -= 1 {  // Empezamos en len-2 para saltar la posición inicial
			append(&result, path[i])
		}
		
		fmt.println("Camino calculado. Longitud:", len(result))
		return result
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
				fmt.println("Tecla ESPACIO presionada - Iniciando cálculo de ruta")
				walk = !walk
				fmt.println("Llamando a pathCalculate...")
				calculatedPath = pathCalculate(objectsMap, beginPos, finishPos)
				fmt.println("pathCalculate completado - Longitud de ruta:", len(calculatedPath))
			}
			
			if walk && len(calculatedPath) > 0 {
				cont += deltaTime
				if(cont >= timeToWalk || characterPos == beginPos) {
					if characterPos != beginPos {
						append(&characterPosArray, characterPos)
					}
					
					// Imprimir información de depuración
					fmt.println("Moviendo desde", characterPos, "a", calculatedPath[0])
					
					characterPos = calculatedPath[0]
					ordered_remove(&calculatedPath, 0)
					
					fmt.println("Quedan", len(calculatedPath), "pasos en el camino")
					
					if characterPos == finishPos {
						append(&characterPosArray, characterPos)
						fmt.println("¡Llegó al destino!")
						travelEnd = true
						walk = false
					}
					
					cont = 0
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
				requireScore = len(characterPosArray) - 1
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
