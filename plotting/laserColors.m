function colour = laserColor(type);

switch type
    case 'chr2'
        colour = [76 199 236];
    case 'CHR2'
        colour = [76 199 236];
    case 'ChR2'
        colour = [76 199 236];
    case 'PV'
        colour = [132 255 150];
    case 'SOM'
        colour = [132 212 255];
    otherwise
        error('Type does not match known types!');
end

if max(colour) > 1
    colour = colour ./ 255;
end