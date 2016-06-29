//
//  main.swift
//  mtg-calculator
//
//  Created by James Quintana on 6/28/16.
//  Copyright © 2016 jraqula. All rights reserved.
//

import Foundation

print("This handy tool will compute suggested land amounts in my complicated way!")
print("Put in card costs from your deck as strings of letters;")
print("only put in the obligatory colors on the rightmost side.")
print("Cards that you need to play early in the game are more important, so add an e.")
print("Example: gue for an early-game card that costs 2GU. Hit enter after each!")
print("--------------------begin------------------")

enum Color: String {
    case Red = "r"
    case Blue = "u"
    case Green = "g"
    case White = "w"
    case Colorless = "c"
    case Black = "b"
}

let allColors: [Color] = [.Red, .White, .Blue, .Black, .Green, .Colorless]

var earlyGameCards: [String] = []
var midLateCards: [String] = []


scope: while true {
    guard let input = readLine(stripNewline: false)?.lowercaseString where input != "\n" else {
        break scope
    }

    if input.containsString("e") {
        //early game card
        let stripped = input.stringByReplacingOccurrencesOfString("e", withString: "")
        earlyGameCards.append(stripped)
    } else {
        midLateCards.append(input)
    }
}

let totalCards = earlyGameCards.count + midLateCards.count
let totalLandsSuggested = totalCards/2

print("You have input \(totalCards) card costs. I estimate")
print("that you should have \(totalLandsSuggested) lands in")
print("your deck (total \(totalCards + totalLandsSuggested)). You may put in a modifier if you want (+- int):")

let modifier: Int = {
    if let modifierString = readLine(stripNewline: true) {
        return Int(modifierString) ?? 0
    }
    return 0
}()

let totalLandsDesired = modifier + totalLandsSuggested

var scores = [Color : Double]()

for code in earlyGameCards {
    let multiplier: Double
    if code.characters.count == 1 {
        multiplier = 2
    } else {
        multiplier = 1.5
    }

    for letter in code.characters {
        if letter == "\n" { continue }
        let thisColor = Color(rawValue: "\(letter)")!
        scores[thisColor] = (scores[thisColor] ?? 0) + multiplier
    }
}

for code in midLateCards {

    var occurrences = [Color : Int]()

    for letter in code.characters {
        if letter == "\n" { continue }
        let thisColor = Color(rawValue: "\(letter)")!
        occurrences[thisColor] = occurrences[thisColor] ?? 0 + 1

        let thisOccurrence = Double(occurrences[thisColor]!)

        scores[thisColor] = (scores[thisColor] ?? 0) + 1.0/thisOccurrence
    }
}

var sum: Double = 0
for value in scores.values {
    sum += value
}

var ratioSum: Double = 0
var ratios = [Color: Double]()
for color in allColors {
    let thisScore = scores[color] ?? 0
    let thisRatio = thisScore / sum
    let adjusted = sqrt(thisRatio)
    ratios[color] = adjusted
    ratioSum += adjusted
}

var closestRoundUp: (Color, Double) = (.Red, 0)
var finals = [Color: Int]()
for color in allColors {
    let thisRatio = ratios[color]!
    let normalized = thisRatio/ratioSum
    let totalCards = normalized * Double(totalLandsDesired)
    let mod = totalCards % 1.0
    if mod > closestRoundUp.1 {
        closestRoundUp = (color, mod)
    }
    let integral = Int(floor(totalCards))
    finals[color] = integral
}

if closestRoundUp.1 > 0 {
    finals[closestRoundUp.0] = finals[closestRoundUp.0]! + 1
}

print("-------Final computed land counts-------")
print("Plains (white): \(finals[.White]!)")
print("Mountains (red): \(finals[.Red]!)")
print("Swamps (black): \(finals[.Black]!)")
print("Islands (blue): \(finals[.Blue]!)")
print("Forests (green): \(finals[.Green]!)")
print("Wastes (colorless): \(finals[.Colorless]!)")

