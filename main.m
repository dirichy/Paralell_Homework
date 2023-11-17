%% This program is used to make a 2D-Model of Ising. 
%% Initialize:
%  T is the temprature
T = permute(1:0.1:3,[3,1,2]);
%  Kb is the Boltzmann constant.
Kb = 1;
%  Size is the size of grid.
Size = 64;
Size2 = Size * Size;
%  Times is the number of steps.
Times = 1000 * Size * Size;
%  J is the spin-spin interaction
J = 1;
%  H is external field
H = zeros(1,1,Thread);
%  Interval is the interval of draw a picture
Interval = 1000;
%  Thread is the number of experiments
Thread = 21;
%  Accepttime: we only use energy when time geq Accepttime
Accepttime = floor(Times * 0.8);
%  Z: the sum of weights. 
Z = zeros(1,1,Thread);
%  UZ: U*Z, where U is the averange internal energy. 
UZ = zeros(1,1,Thread);
%  sumH2: The sum of H^2 with weights. 
sumH2 = zeros(1,1,Thread);
%% Step 1: Generate a grid. 
grid = GenerateGrid(Size,Thread);

%% Step 2: Initiallize. caculate energy, 
Energy = getEnergyOfGrid(Size, grid, J, H);

%% open the video stream
fname = './Ising.avi';
vidObj = VideoWriter(fname);
vidObj.FrameRate =floor(20000/Interval);
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
  Flag = Flag * 2 - ones(1,1,Thread);
  Flag = - Flag;
  grid(coordinate(1),coordinate(2),:) = grid(coordinate(1),coordinate(2),:) .* Flag;
%% Step 3.5: sum Z and uZ. 
  Z = Z + exp(-Kb * Energy ./ T);
  UZ = UZ + Energy .* exp(-Kb * Energy ./ T);
  sumH2 = sumH2 + Energy .* Energy .* exp(-Kb * Energy ./ T);
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
U = UZ ./ Z;
C = Kb ./ T ./ T .* (sumH2 ./ Z - U .* U);
u = U / Size2;
c = C / Size2;
%% Step 5: plot the u-T and c-T picture. 
u = permute(u,[3,2,1]);
T = permute(T,[3,2,1]);
c = permute(c,[3,2,1]);
plot(T,u);
plot(T,c);