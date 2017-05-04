//
//  MusicalModel.swift
//  Timeline Example iOS
//
//  Created by James Bean on 5/3/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import ArithmeticTools

public struct MetricalDuration: Rational {
    
    public static let zero = MetricalDuration(0,1)
    
    public let numerator: Int
    public let denominator: Int
    
    public init(_ numerator: Int, _ denominator: Int) {
        
        guard denominator.isPowerOfTwo else {
            fatalError("Cannot create a MetricalDuration with a non-power-of-two denominator")
        }
        
        self.numerator = numerator
        self.denominator = denominator
    }
}


/// - TODO: Add Double value ?
public struct Tempo {
    
    /// In Seconds
    internal var durationOfBeat: Double {
        return 60 / value
    }
    
    internal var doubleValue: Double {
        return value / Double(subdivision)
    }
    
    /// Value of tempo.
    public let value: Double
    
    /// 1 = whole note, 2 = half note, 4 = quarter note, 8 = eighth note, 16 = sixteenth note,
    /// etc.
    public let subdivision: Int
    
    /// Creates a `Tempo` with the given `value` for the given `subdivision`.
    public init(_ value: Double, subdivision: Int = 4) {
        
        guard subdivision != 0 else {
            fatalError("Cannot create a tempo with a subdivision of 0")
        }
        
        self.value = value
        self.subdivision = subdivision
    }
    
    // Seconds
    public func duration(forBeatAt subdivision: Int) -> Double {
        
        guard subdivision.isPowerOfTwo else {
            fatalError("Subdivision must be a power-of-two")
        }
        
        let quotient = Double(subdivision) / Double(self.subdivision)
        return durationOfBeat / quotient
    }
}

extension Tempo {
    
    public static func == (lhs: Tempo, rhs: Tempo) -> Bool {
        return lhs.doubleValue == rhs.doubleValue
    }
}

public struct MetricalStructure {
    
    public let meters: [Meter]
    
    public init(meters: [Meter]) {
        self.meters = meters
    }
}

/// - TODO: Move to `dn-m/Rhythm`.
public struct Meter: Rational {
    
    public let numerator: Int
    public let denominator: Int
    
    public init(_ numerator: Int, _ denominator: Int) {
        
        // TODO: Include denominators with power-of-two factors (28, 44, etc.),
        guard denominator.isPowerOfTwo else {
            fatalError("Cannot create a Meter with a non-power-of-two denominator")
        }
        
        guard numerator > 0 else {
            fatalError("Cannot create a Meter with a numerator of 0")
        }
        
        self.numerator = numerator
        self.denominator = denominator
    }
    
    // Change [Double] -> [Seconds]
    public func offsets(tempo: Tempo) -> [Double] {
        let durationForBeat = tempo.duration(forBeatAt: denominator)
        return (0..<numerator).map { Double($0) * durationForBeat }
    }
    
    /// - returns: Duration of measure at the given `tempo`.
    public func duration(at tempo: Tempo) -> Double {
        return Double(numerator) * tempo.duration(forBeatAt: denominator)
    }
}

public struct Measure {
    
    let number: Int
    let meter: Meter
    
    public init(number: Int, meter: Meter) {
        self.number = number
        self.meter = meter
    }
}
