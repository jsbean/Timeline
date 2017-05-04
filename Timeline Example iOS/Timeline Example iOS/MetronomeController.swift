//
//  MetronomeController.swift
//  Timeline Example iOS
//
//  Created by James Bean on 5/3/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import Collections

public class MetronomeController {
    
    public typealias Action = () -> ()
    
    public enum Level {
        case upbeat
        case downbeat
    }
    
    public var actionByOffset: [(Double, Action)] {
        
        typealias Result = [(Double, Action)]
        
        func accumulate(meters: [Meter], accumOffset: Double, result: Result) -> Result {
            
            guard let (meter, tail) = meters.destructured else {
                return result
            }
            
            let offsets = meter.offsets(tempo: tempo)
            let actions = self.actions(for: meter)
            
            let actionByOffset = zip(offsets, actions).map { localOffset, action in
                (accumOffset + localOffset, action)
            }
            
            let accumOffset = accumOffset + meter.duration(at: tempo)
            let result = result + actionByOffset
            return accumulate(meters: tail, accumOffset: accumOffset, result: result)
        }
        
        return accumulate(meters: structure.meters, accumOffset: 0, result: [])
    }
    
    private let structure: MetricalStructure
    
    // TODO: decouple model tempo from playback tempo
    private let tempo: Tempo
    
    // TODO: Create hierarchical structure of meter
    private let onDownbeat: (Meter, Int, Tempo) -> ()
    private let onUpbeat: (Meter, Int, Tempo) -> ()
    
    public init(
        structure: MetricalStructure,
        tempo: Tempo,
        onDownbeat: @escaping (Meter, Int, Tempo) -> (),
        onUpbeat: @escaping (Meter, Int, Tempo) -> ()
    )
    {
        self.structure = structure
        self.tempo = tempo
        self.onDownbeat = onDownbeat
        self.onUpbeat = onUpbeat
    }
    
    func actions(for meter: Meter) -> [Action] {
        
        let (_, upbeats) = Array(0 ..< meter.numerator).destructured!
        
        let downbeat = {
            self.onDownbeat(meter, 1, self.tempo)
        }
        
        return downbeat + upbeats.map { beat in
            { self.onUpbeat(meter, beat + 1, self.tempo) }
        }
    }
}
