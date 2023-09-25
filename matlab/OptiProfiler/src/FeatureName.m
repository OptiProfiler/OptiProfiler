classdef FeatureName
    %ENUMERATION of the available features.
    %
    
    enumeration
        CUSTOM ('custom')
        NOISY ('noisy')
        PLAIN ('plain')
        REGULARIZED ('regularized')
        TOUGH ('tough')
        TRUNCATED ('truncated')
    end
    properties
        value
    end
    methods
        function obj = FeatureName(inputValue)
            obj.value = inputValue;
        end
    end
end