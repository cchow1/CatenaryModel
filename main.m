%%
Pressure = 101000; %Pa

%Dyneema Material Properties
Length = 1.0; %m
Width = 1.0; %m
D = 3*10^(-3); %m
CrossArea = pi*D^2/4;
E = 150*10^9; %Pa

d_0 = 0.01; % Initial deflection guess, m
C_0 = 7; % Initial expansion constant guess, m

% For the initial calculation, the total force from pressure applied to the door is
% taken to be equally supported by all of the horizontal cables.

numCables = floor(Width/0.1) + floor(Length/0.1); % Find the number of cables placed in 10cm intervals
force_per_length = (Pressure * Width^2)/numCables/Length; % Force per length acting on each cable

x_distance = [0;10;20;30;40]; % denotes location of cables in an array --> center rope is 0 cm!! I change this to meters later don't worry! 
size_x = size(x_distance);

continueIterate = true;

while continueIterate
    findC = @(C) C*cosh((0.5)/C) - C - d_0; 
    C = fzero(findC, C_0);
    end_Tension = force_per_length * (C + d_0);
    stress = end_Tension/CrossArea;
    strain = stress/E;
    deltaLength = strain*Width;
    ArcLength = deltaLength + Width;
    newC = @(C) C*sinh((Width/2)/C) - ArcLength/2;
    C = fzero(newC, 0.8);
    deflection = sqrt(C^2 + (ArcLength/2)^2) - C;
    
    if abs((deflection-d_0)/d_0) < 0.0001
        disp(['The deflection of the horizontal cables is ' num2str(deflection)]);
        break
    end
    
    d_0 = deflection;
    C_0 = C;
    
end

main_C = C;

catenary = @(c,x) c*cosh(x/c); % Catenary equation

% Take force_per_cable to increase linearly with distance from center rope
distance_from_center = (x_distance(2:size_x(1)) - x_distance(1))/100; % Calculates how far each segment is from the center rope
segment_length = (x_distance(2:size_x(1)) - x_distance(1:size_x(1)-1))/100; % Calculates the length of each rope segment (it's equal for now) 
force_per_segment_reversed = (segment_length * 0.5 .* distance_from_center)/0.005 * force_per_length; % Creates an array of the forces acting per segment in reverse order oops 
force_per_segment = flipud(force_per_segment_reversed); % haha now this array makes sense! 

for i = 1:1:4 % number of ropes
  
        current_C = catenary (main_C, x_distance(i)/10); % Get the C value of the current cable
        current_yB = catenary(current_C, 0.5); % Find the distance from the x-axis to the endpoint of the cable
        max_Tension(i) = force_per_segment(i) * current_yB; % Calculate the tension at the endpoint of the cable using forces per segment
        current_Deflection(i) = current_yB - current_C; % Find the deflection of the current cable
        disp(['The deflection after ' num2str(i*10) 'cm is ' num2str(current_Deflection(i)*100) 'cm.']);
        %disp(['The maximum tangential tension in the cable at this point is ' num2str(max_Tension(i)) 'N.']);
        
end

disp(['The tension on the rope matrix is as follows: ' mat2str(max_Tension) ' N.']);
disp(['The deflections on the rope matrix is as follows: ' mat2str(current_Deflection*100) ' cm.']);
