%% This program is used to make a 2D-Model of Ising. 
%% Initialize:
clear; 
%  T is the temprature, the third dimension represents different expenriment. 
T = permute(2.2:0.01:2.3,[3,1,2]); 
%  Thread is the number of experiments
Thread = size(T,3); 
%  H is external field
H = zeros(1,1,Thread); 
%  Kb is the Boltzmann constant. 
Kb = 1; 
%  Size is the size of grid.
Size = 10;
Size2 = Size * Size;
%  Times is the number of steps.
Times = 1000000 * Size * Size;
%  J is the spin-spin interaction
J = 1;
%  Interval is the interval of draw a picture
Interval = 100000;
%  Accepttime: we only use energy when time geq Accepttime
Accepttime = floor(Times * 0.8);
%  sumH2: The sum of Energy^2. 
sumH2 = zeros(1,1,Thread); 
%  sumH: The sum of Energy. 
sumH = zeros(1,1,Thread); 
%  sumMag: The sum of Mag. 
sumMag = zeros(1,1,Thread);
%% Step 1: Generate a grid. 
grid = GenerateGrid(Size,Thread);
%  Magnet: The internal Magnet of grid. 
Magnet = sum(sum(grid));
%% Step 2: Initiallize. caculate energy, 
Energy = getEnergyOfGrid(Size, grid, J, H);

%% open the video stream
fname = './Ising.avi';
vidObj = VideoWriter(fname);
vidObj.FrameRate =20;
open(vidObj);
%% Step 3: 循环
for time = 1:Times
%% Step 3.1: Choose a point randomly.
 coordinate = ceil(rand(2,1,Thread) .* Size);
%% Step 3.2： Caculate the DeltaEnergy. 
 DeltaEnergy = getDeltaEnergy(Size, grid, J, H, coordinate);
%% Step 3.3: judge whether to accept the change or not. 
 Flag = WhetherAccept(DeltaEnergy, Kb, T,Thread);
%% Step 3.4: If accept, change the grid and energy. 
  Energy = Energy + DeltaEnergy .* Flag;
  Magnet = Magnet - 2 .* Flag .* grid(coordinate(1),coordinate(2),:);
  Flag = Flag * 2 - ones(1,1,Thread);
  Flag = - Flag;
  grid(coordinate(1),coordinate(2),:) = grid(coordinate(1),coordinate(2),:) .* Flag;
%% Step 3.5: sum Z and uZ. 
   if time > Accepttime
     sumH = sumH + Energy; 
     sumH2 = sumH2 + Energy .* Energy; 
     sumMag = sumMag + Magnet;
   end
%% Step 3.5: plot picture of grid. 
 if mod(time,floor(Times/100))==0
  time/Times
 end
 if mod(time,Interval) == 0
   image(1000*grid(:,:,1));
   drawnow
   colormap("gray");
   I = getframe(gcf);
   writeVideo(vidObj,I);
 end
end
close(vidObj);
%% Step 4: caculate the averange internal energy, u, and the specific heat, c. 
U = sumH ./ (Times - Accepttime); 
C = Kb ./ T ./ T .* (sumH2 ./ (Times - Accepttime) - U .* U); 
M = sumMag ./ (Times - Accepttime);
u = U ./ Size2; 
c = C ./ Size2; 
m = M ./ Size2; 
%% Step 5: plot the u-T and c-T picture. 
u = permute(u,[3,2,1]); 
T = permute(T,[3,2,1]); 
c = permute(c,[3,2,1]); 
m = permute(m,[3,2,1]); 
plot(T,u); 
plot(T,c); 