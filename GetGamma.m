function Gamma = GetGamma(Size,grid,Thread)
 Gamma = zeros(1,1,Thread,Size)
  for i = 1:Size
   Gamma(:,:,:,i) = sum(sum(grid .* circshift(grid,[0 i 0])));
  end
end