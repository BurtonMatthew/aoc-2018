import Control.Monad
import Data.Char
import Data.List
import Data.Map (fromListWith, toList)
import Text.ParserCombinators.ReadP

main :: IO ()
main = do
    fileLines <- liftM lines (readFile "input6.txt")
    putStrLn $ (++) "Part 1: " $ show $ solvePart1 $  map (fst . head . readP_to_S parseCoord) fileLines
    putStrLn $ (++) "Part 2: " $ show $ solvePart2 $  map (fst . head . readP_to_S parseCoord) fileLines

parseCoord :: ReadP (Int,Int)
parseCoord = do
    x <- liftM read $ munch1 isDigit
    char ','
    skipSpaces
    y <- liftM read $ munch1 isDigit
    return (x,y)

solvePart1 :: [(Int,Int)] -> Int
solvePart1 points = snd $ head $ sortBy largestDist $ countInstances $ filter notNullOrHull $ map closestPointTo allCoords
    where 
        minX :: Int
        minX = head $ sort $ map fst points
        maxX :: Int
        maxX = last $ sort $ map fst points
        minY :: Int
        minY = head $ sort $ map snd points
        maxY :: Int
        maxY = last $ sort $ map snd points
        allCoords :: [(Int,Int)]
        allCoords = [(x,y) | x <- [minX..maxX], y <- [minY..maxY]]
        hullCoords :: [(Int,Int)]
        hullCoords = filter (\(x,y) -> x == minX || x == maxX || y == minY || y == maxY) allCoords
        nullCoord :: (Int,Int)
        nullCoord = ((-1),(-1))
        manDist :: (Int,Int) -> (Int,Int) -> Int
        manDist (x1,y1) (x2,y2) = abs (x2-x1) + abs (y2-y1)
        closestPointTo :: (Int,Int) -> (Int,Int)
        closestPointTo (x,y) = fst $ foldl' (compDists (x, y)) (nullCoord, maxBound) points
        compDists :: (Int,Int) -> ((Int,Int),Int) -> (Int,Int) -> ((Int,Int),Int)
        compDists (x, y) ((x1,y1), d) (x2,y2)
            | newDist < d = ((x2,y2), newDist)
            | newDist == d = (nullCoord, d)
            | otherwise = ((x1,y1), d)
            where newDist = manDist (x,y) (x2,y2)
        largestDist :: ((Int,Int),Int) -> ((Int,Int),Int) -> Ordering
        largestDist ((_,_),d1) ((_,_),d2) = compare d2 d1
        notNullOrHull :: (Int,Int) -> Bool
        notNullOrHull (x,y) = not $ (x,y) == nullCoord || (x,y) `elem` nearestHullPoints
        nearestHullPoints :: [(Int,Int)]
        nearestHullPoints = nub $ map closestPointTo hullCoords

countInstances :: (Ord a, Num b) => [a] -> [(a, b)]
countInstances keys = toList $ fromListWith (+) $ zip keys $ repeat 1

-- Slow and uses hardcoded numbers
solvePart2 :: [(Int,Int)] -> Int
solvePart2 points = length $ filter coordIsSafe allCoords
    where
        minX = head $ sort $ map fst points
        maxX = last $ sort $ map fst points
        minY = head $ sort $ map snd points
        maxY = last $ sort $ map snd points
        allCoords = [(x,y) | x <- [minX-500..maxX+500], y <- [minY-500..maxY+500]]
        manDist (x1,y1) (x2,y2) = abs (x2-x1) + abs (y2-y1)
        coordIsSafe (x,y) = (sum $ map (manDist (x,y)) points) < 10000