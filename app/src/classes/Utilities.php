<?php

class Utilities { 
    public static function executeCommand($command)
    {
        exec($command, $output, $returnVar);
        if ($returnVar !== 0) {
            throw new RuntimeException("Command failed: $command\nOutput: " . implode("\n", $output));
        }
        return $output;
    }
    
}