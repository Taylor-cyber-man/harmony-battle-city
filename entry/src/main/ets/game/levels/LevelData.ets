import { TileType, EnemyType } from '../utils/Constants'

let stage1Terrain: number[][] = [
  [0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 1, 1, 2, 2, 1, 1, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0],
  [0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0],
  [2, 2, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 2, 2],
  [0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0],
  [0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0]
]

let stage2Terrain: number[][] = [
  [0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
  [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [1, 1, 0, 0, 1, 1, 0, 0, 1, 2, 2, 1, 0, 0, 1, 1],
  [0, 0, 0, 0, 1, 1, 0, 0, 1, 2, 2, 1, 0, 0, 1, 1],
  [1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1],
  [1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1],
  [0, 0, 0, 0, 1, 1, 2, 2, 1, 0, 0, 1, 2, 2, 1, 1],
  [0, 0, 0, 0, 1, 1, 2, 2, 1, 2, 0, 1, 3, 3, 1, 1],
  [1, 1, 1, 0, 3, 3, 3, 3, 2, 2, 0, 0, 0, 0, 0, 0],
  [1, 1, 1, 0, 3, 1, 1, 0, 1, 1, 0, 0, 2, 2, 2, 2],
  [2, 1, 1, 0, 3, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
  [0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1],
  [0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
  [0, 1, 1, 0, 3, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0],
  [0, 1, 1, 0, 3, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0],
  [0, 1, 1, 0, 3, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0]
]

let stage3Terrain: number[][] = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [1, 0, 1, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0],
  [1, 0, 1, 0, 3, 0, 3, 0, 1, 0, 0, 1, 0, 3, 0, 3],
  [0, 0, 0, 0, 0, 1, 3, 1, 1, 0, 0, 1, 1, 3, 1, 0],
  [2, 2, 0, 0, 3, 0, 2, 0, 1, 0, 0, 0, 1, 3, 0, 3],
  [1, 1, 0, 0, 0, 1, 3, 1, 0, 0, 0, 0, 1, 3, 1, 0],
  [0, 0, 0, 0, 3, 0, 3, 0, 0, 2, 2, 0, 0, 3, 0, 3],
  [0, 0, 0, 0, 0, 1, 3, 1, 0, 2, 2, 0, 1, 2, 1, 0],
  [1, 1, 1, 1, 0, 0, 2, 0, 1, 1, 1, 1, 0, 3, 0, 0],
  [1, 1, 1, 1, 0, 1, 3, 0, 0, 1, 1, 3, 3, 3, 1, 0],
  [0, 1, 1, 0, 3, 2, 3, 0, 0, 1, 1, 0, 0, 3, 0, 3],
  [0, 1, 1, 0, 0, 1, 3, 1, 1, 0, 0, 1, 1, 3, 1, 0],
  [1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0],
  [1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0],
  [0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0]
]

let stage4Terrain: number[][] = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 1, 0, 1, 0, 0, 5, 5, 5, 5, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 1, 5, 5, 5, 5, 1, 0, 1, 0, 1, 0],
  [0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 0, 0, 0, 0, 0, 0],
  [0, 1, 0, 1, 0, 1, 0, 5, 5, 0, 1, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 0, 5, 5, 0, 0, 0, 1, 0, 1, 0],
  [0, 0, 0, 0, 0, 1, 5, 5, 5, 5, 1, 0, 0, 0, 0, 0],
  [2, 0, 1, 0, 0, 0, 5, 2, 2, 5, 0, 0, 0, 1, 0, 2],
  [2, 0, 1, 0, 0, 1, 5, 2, 2, 5, 1, 0, 0, 1, 0, 2],
  [0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 0, 0, 0, 0, 0, 0],
  [0, 1, 0, 1, 0, 1, 0, 5, 5, 0, 1, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 0, 2, 2, 0, 0, 0, 1, 0, 1, 0],
  [0, 0, 0, 0, 5, 5, 0, 0, 0, 0, 5, 5, 0, 0, 0, 0],
  [0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0]
]

let stage5Terrain: number[][] = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0],
  [0, 1, 1, 0, 1, 0, 1, 4, 4, 1, 0, 1, 0, 1, 1, 0],
  [0, 0, 0, 0, 1, 0, 0, 4, 4, 0, 0, 1, 0, 0, 0, 0],
  [1, 1, 1, 1, 0, 0, 4, 4, 4, 4, 0, 0, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 4, 4, 2, 2, 4, 4, 0, 0, 0, 0, 0],
  [0, 0, 1, 0, 0, 4, 2, 2, 2, 2, 4, 0, 0, 1, 0, 0],
  [0, 0, 1, 0, 4, 4, 2, 0, 0, 2, 4, 4, 0, 1, 0, 0],
  [0, 0, 1, 0, 0, 4, 2, 2, 2, 2, 4, 0, 0, 1, 0, 0],
  [0, 0, 0, 0, 0, 4, 4, 2, 2, 4, 4, 0, 0, 0, 0, 0],
  [1, 1, 1, 1, 0, 0, 4, 4, 4, 4, 0, 0, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0],
  [0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0]
]

let stage6Terrain: number[][] = [
  [0, 0, 3, 0, 0, 0, 3, 0, 0, 3, 0, 0, 0, 3, 0, 0],
  [0, 1, 3, 1, 0, 1, 3, 1, 1, 3, 1, 0, 1, 3, 1, 0],
  [0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0],
  [3, 3, 3, 3, 0, 0, 1, 1, 1, 1, 0, 0, 3, 3, 3, 3],
  [0, 0, 1, 0, 0, 3, 1, 0, 0, 1, 3, 0, 0, 1, 0, 0],
  [0, 0, 1, 0, 3, 3, 0, 0, 0, 0, 3, 3, 0, 1, 0, 0],
  [0, 0, 0, 0, 3, 0, 1, 2, 2, 1, 0, 3, 0, 0, 0, 0],
  [1, 1, 0, 0, 3, 0, 2, 0, 0, 2, 0, 3, 0, 0, 1, 1],
  [1, 1, 0, 0, 3, 0, 2, 0, 0, 2, 0, 3, 0, 0, 1, 1],
  [0, 0, 0, 0, 3, 0, 1, 2, 2, 1, 0, 3, 0, 0, 0, 0],
  [0, 0, 1, 0, 0, 3, 0, 0, 0, 0, 3, 0, 0, 1, 0, 0],
  [0, 0, 1, 0, 0, 3, 1, 0, 0, 1, 3, 0, 0, 1, 0, 0],
  [3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3],
  [0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0]
]

let stage7Terrain: number[][] = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 1, 1, 0, 0, 1, 0, 2, 2, 0, 1, 0, 0, 1, 1, 0],
  [0, 1, 1, 0, 1, 0, 0, 2, 2, 0, 0, 1, 0, 1, 1, 0],
  [0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0],
  [0, 1, 0, 1, 0, 0, 0, 2, 2, 0, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 1, 2, 2, 2, 2, 1, 0, 1, 0, 1, 0],
  [0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0],
  [0, 0, 2, 2, 0, 0, 2, 2, 0, 0, 0, 0, 2, 2, 0, 0],
  [0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0],
  [0, 1, 0, 1, 0, 1, 2, 2, 2, 2, 1, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 0, 2, 2, 0, 0, 0, 1, 0, 1, 0],
  [0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0],
  [0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0]
]

let stage8Terrain: number[][] = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 5, 5, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 5, 5, 0],
  [0, 5, 5, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 5, 5, 0],
  [0, 0, 0, 0, 1, 0, 0, 3, 3, 0, 0, 1, 0, 0, 0, 0],
  [0, 3, 3, 0, 1, 0, 4, 4, 4, 4, 0, 1, 0, 3, 3, 0],
  [0, 3, 3, 0, 1, 0, 4, 2, 2, 4, 0, 1, 0, 3, 3, 0],
  [0, 0, 0, 0, 1, 0, 4, 2, 2, 4, 0, 1, 0, 0, 0, 0],
  [1, 0, 0, 1, 2, 0, 4, 4, 4, 4, 0, 2, 1, 0, 0, 1],
  [1, 0, 0, 1, 2, 0, 4, 4, 4, 4, 0, 2, 1, 0, 0, 1],
  [0, 0, 0, 0, 1, 0, 4, 2, 2, 4, 0, 1, 0, 0, 0, 0],
  [0, 4, 4, 0, 1, 0, 4, 2, 2, 4, 0, 1, 0, 4, 4, 0],
  [0, 4, 4, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 4, 4, 0],
  [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
  [0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0]
]

let stage9Terrain: number[][] = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 2, 2, 0, 0, 2, 2, 0, 0, 2, 2, 0, 0, 2, 2, 0],
  [2, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 2],
  [2, 0, 0, 2, 0, 1, 1, 0, 0, 1, 1, 0, 2, 0, 0, 2],
  [0, 2, 2, 0, 1, 2, 2, 1, 1, 2, 2, 1, 0, 2, 2, 0],
  [0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0],
  [1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1],
  [1, 1, 0, 3, 0, 0, 0, 1, 1, 0, 0, 0, 3, 0, 1, 1],
  [1, 1, 0, 3, 0, 0, 0, 1, 1, 0, 0, 0, 3, 0, 1, 1],
  [1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1],
  [0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0],
  [0, 2, 2, 0, 1, 2, 2, 1, 1, 2, 2, 1, 0, 2, 2, 0],
  [2, 0, 0, 2, 0, 1, 1, 0, 0, 1, 1, 0, 2, 0, 0, 2],
  [0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0]
]

let stage10Terrain: number[][] = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 2, 0, 3, 0, 5, 0, 2, 2, 0, 5, 0, 3, 0, 2, 0],
  [0, 0, 1, 3, 0, 5, 1, 0, 0, 1, 5, 0, 3, 1, 0, 0],
  [1, 0, 1, 0, 0, 5, 0, 1, 1, 0, 5, 0, 0, 1, 0, 1],
  [0, 1, 0, 1, 0, 5, 4, 0, 0, 4, 5, 0, 1, 0, 1, 0],
  [0, 0, 0, 0, 0, 5, 4, 2, 2, 4, 5, 0, 0, 0, 0, 0],
  [3, 3, 0, 2, 0, 5, 0, 2, 2, 0, 5, 0, 2, 0, 3, 3],
  [3, 3, 0, 2, 0, 5, 4, 0, 0, 4, 5, 0, 2, 0, 3, 3],
  [3, 3, 0, 2, 0, 5, 4, 2, 2, 4, 5, 0, 2, 0, 3, 3],
  [0, 0, 0, 0, 0, 5, 0, 2, 2, 0, 5, 0, 0, 0, 0, 0],
  [0, 2, 0, 2, 0, 5, 4, 0, 0, 4, 5, 0, 2, 0, 2, 0],
  [1, 0, 1, 0, 0, 5, 4, 1, 1, 4, 5, 0, 0, 1, 0, 1],
  [0, 0, 1, 0, 0, 5, 0, 0, 0, 0, 5, 0, 0, 1, 0, 0],
  [0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0],
  [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0]
]

// 返回10个关卡的地形数据，每关16x16二维数组
function getStageTerrain(stageIndex: number): number[][] {
  if (stageIndex === 0) {
    return stage1Terrain
  }
  if (stageIndex === 1) {
    return stage2Terrain
  }
  if (stageIndex === 2) {
    return stage3Terrain
  }
  if (stageIndex === 3) {
    return stage4Terrain
  }
  if (stageIndex === 4) {
    return stage5Terrain
  }
  if (stageIndex === 5) {
    return stage6Terrain
  }
  if (stageIndex === 6) {
    return stage7Terrain
  }
  if (stageIndex === 7) {
    return stage8Terrain
  }
  if (stageIndex === 8) {
    return stage9Terrain
  }
  return stage10Terrain
}

function getStageEnemySequence(stageIndex: number): number[] {
  let sequence: number[] = []
  if (stageIndex === 0) {
    for (let i = 0; i < 10; i++) {
      sequence[i] = EnemyType.LIGHT
    }
  } else if (stageIndex === 1) {
    for (let i = 0; i < 8; i++) {
      sequence[i] = EnemyType.LIGHT
    }
    sequence[8] = EnemyType.ARMORED_CAR
    sequence[9] = EnemyType.ARMORED_CAR
  } else if (stageIndex === 2) {
    for (let i = 0; i < 6; i++) {
      sequence[i] = EnemyType.LIGHT
    }
    sequence[6] = EnemyType.ARMORED_CAR
    sequence[7] = EnemyType.FAST_SHOT
    sequence[8] = EnemyType.FAST_SHOT
    sequence[9] = EnemyType.HEAVY
  } else if (stageIndex === 3) {
    for (let i = 0; i < 5; i++) {
      sequence[i] = EnemyType.LIGHT
    }
    sequence[5] = EnemyType.ARMORED_CAR
    sequence[6] = EnemyType.ARMORED_CAR
    sequence[7] = EnemyType.FAST_SHOT
    sequence[8] = EnemyType.FAST_SHOT
    sequence[9] = EnemyType.HEAVY
  } else if (stageIndex === 4) {
    for (let i = 0; i < 4; i++) {
      sequence[i] = EnemyType.LIGHT
    }
    sequence[4] = EnemyType.ARMORED_CAR
    sequence[5] = EnemyType.ARMORED_CAR
    sequence[6] = EnemyType.FAST_SHOT
    sequence[7] = EnemyType.FAST_SHOT
    sequence[8] = EnemyType.HEAVY
    sequence[9] = EnemyType.HEAVY
  } else if (stageIndex === 5) {
    for (let i = 0; i < 3; i++) {
      sequence[i] = EnemyType.LIGHT
    }
    sequence[3] = EnemyType.ARMORED_CAR
    sequence[4] = EnemyType.ARMORED_CAR
    sequence[5] = EnemyType.FAST_SHOT
    sequence[6] = EnemyType.FAST_SHOT
    sequence[7] = EnemyType.FAST_SHOT
    sequence[8] = EnemyType.HEAVY
    sequence[9] = EnemyType.HEAVY
  } else if (stageIndex === 6) {
    for (let i = 0; i < 2; i++) {
      sequence[i] = EnemyType.LIGHT
    }
    sequence[2] = EnemyType.ARMORED_CAR
    sequence[3] = EnemyType.ARMORED_CAR
    sequence[4] = EnemyType.FAST_SHOT
    sequence[5] = EnemyType.FAST_SHOT
    sequence[6] = EnemyType.FAST_SHOT
    sequence[7] = EnemyType.HEAVY
    sequence[8] = EnemyType.HEAVY
    sequence[9] = EnemyType.HEAVY
  } else if (stageIndex === 7) {
    for (let i = 0; i < 2; i++) {
      sequence[i] = EnemyType.LIGHT
    }
    sequence[2] = EnemyType.ARMORED_CAR
    sequence[3] = EnemyType.FAST_SHOT
    sequence[4] = EnemyType.FAST_SHOT
    sequence[5] = EnemyType.FAST_SHOT
    sequence[6] = EnemyType.HEAVY
    sequence[7] = EnemyType.HEAVY
    sequence[8] = EnemyType.HEAVY
    sequence[9] = EnemyType.HEAVY
  } else if (stageIndex === 8) {
    sequence[0] = EnemyType.LIGHT
    sequence[1] = EnemyType.ARMORED_CAR
    sequence[2] = EnemyType.FAST_SHOT
    sequence[3] = EnemyType.FAST_SHOT
    sequence[4] = EnemyType.FAST_SHOT
    sequence[5] = EnemyType.HEAVY
    sequence[6] = EnemyType.HEAVY
    sequence[7] = EnemyType.HEAVY
    sequence[8] = EnemyType.HEAVY
    sequence[9] = EnemyType.HEAVY
  } else {
    sequence[0] = EnemyType.FAST_SHOT
    sequence[1] = EnemyType.FAST_SHOT
    sequence[2] = EnemyType.FAST_SHOT
    sequence[3] = EnemyType.HEAVY
    sequence[4] = EnemyType.HEAVY
    sequence[5] = EnemyType.HEAVY
    sequence[6] = EnemyType.HEAVY
    sequence[7] = EnemyType.HEAVY
    sequence[8] = EnemyType.HEAVY
    sequence[9] = EnemyType.HEAVY
  }
  return sequence
}

export { getStageTerrain, getStageEnemySequence, getEnemySpawnPoints }

function getEnemySpawnPoints(stageIndex: number): number[][] {
  if (stageIndex === 0) {
    return [[0, 0], [4, 0], [11, 0]]
  }
  if (stageIndex === 1) {
    return [[1, 0], [6, 0], [13, 0]]
  }
  if (stageIndex === 2) {
    return [[0, 0], [4, 0], [11, 0]]
  }
  if (stageIndex === 3) {
    return [[0, 0], [5, 0], [12, 0]]
  }
  if (stageIndex === 4) {
    return [[1, 0], [6, 0], [12, 0]]
  }
  if (stageIndex === 5) {
    return [[0, 0], [4, 0], [12, 0]]
  }
  if (stageIndex === 6) {
    return [[0, 0], [4, 0], [13, 0]]
  }
  if (stageIndex === 7) {
    return [[1, 0], [6, 0], [12, 0]]
  }
  if (stageIndex === 8) {
    return [[0, 0], [4, 0], [12, 0]]
  }
  return [[0, 0], [4, 0], [11, 0]]
}
