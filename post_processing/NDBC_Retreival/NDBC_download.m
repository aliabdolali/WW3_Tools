clear all
clc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program downloads the hidtorical NDBC data for a given year and   %
% within a box, defiend by the user                                      %
% Ali Abdolali (EMC/NCEP/NOAA ali.abdolali@noaa.gov                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%WDIR   Wind direction (the direction the wind is coming from in degrees clockwise from true N) during the same period used for WSPD. See Wind Averaging Methods
%WSPD   Wind speed (m/s) averaged over an eight-minute period for buoys and a two-minute period for land stations. Reported Hourly. See Wind Averaging Methods.
%GST    Peak 5 or 8 second gust speed (m/s) measured during the eight-minute or two-minute period. The 5 or 8 second period can be determined by payload, See the Sensor Reporting, Sampling, and Accuracy section.
%WVHT   Significant wave height (meters) is calculated as the average of the highest one-third of all of the wave heights during the 20-minute sampling period. See the Wave Measurements section.
%DPD    Dominant wave period (seconds) is the period with the maximum wave energy. See the Wave Measurements section.
%APD    Average wave period (seconds) of all waves during the 20-minute period. See the Wave Measurements section.
%MWD    The direction from which the waves at the dominant period (DPD) are coming. The units are degrees from true North, increasing clockwise, with North as 0 (zero) degrees and East as 90 degrees. See the Wave Measurements section.
%PRES   Sea level pressure (hPa). For C-MAN sites and Great Lakes buoys, the recorded pressure is reduced to sea level using the method described in NWS Technical Procedures Bulletin 291 (11/14/80). ( labeled BAR in Historical files)
%ATMP   Air temperature (Celsius). For sensor heights on buoys, see Hull Descriptions. For sensor heights at C-MAN stations, see C-MAN Sensor Locations
%WTMP   Sea surface temperature (Celsius). For buoys the depth is referenced to the hull's waterline. For fixed platforms it varies with tide, but is referenced to, or near Mean Lower Low Water (MLLW).
%DEWP   Dewpoint temperature taken at the same height as the air temperature measurement.
%VIS    Station visibility (nautical miles). Note that buoy stations are limited to reports from 0 to 1.6 nmi.
%PTDY   Pressure Tendency is the direction (plus or minus) and the amount of pressure change (hPa)for a three hour period ending at the time of observation. (not in Historical files)
%TIDE   The water level in feet above or below Mean Lower Low Water (MLLW).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%    INPUT    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Lon_min=-82;
Lon_max=-72;
Lat_min=30;
Lat_max=40;
yr=2018;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read the shape file for the NDBC buoy
S=shaperead('shape/buoylocations.shp');
for i=1:length(S)
B{i,1}=S(i).STATION_ID;
X(i,1)=S(i).X;
Y(i,1)=S(i).Y;
URL{i,:}=S(i).URL;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Find the index of buoys inside the bounding box
[ii,jj]=find(X>=Lon_min & X<=Lon_max & Y>=Lat_min & Y<=Lat_max);


disp('Start ...')
disp(['year = ',num2str(yr)])
disp(['Bounding Box: Longitude [',num2str(Lon_min),' ',num2str(Lon_max),'],... Latitude [',num2str(Lat_min),' ',num2str(Lat_max),'].'])

m=0; %Standard Meteorological including wave
n=0; % Continuous Wind

for iii=1:length(ii)
    i=ii(iii);
myURL=['https://www.ndbc.noaa.gov/view_text_file.php?filename=',B{i},'h',num2str(yr),'.txt.gz&dir=data/historical/stdmet/'];
[str,status] = urlread(myURL);
%if wave data is available
if status==1
    m=m+1;
urlwrite(myURL,[B{i},'h',num2str(yr),'.txt']);
XY1(m,1)=X(i);
XY1(m,2)=Y(i);
II1(m,1)=i;
disp(['Downloading NDBC#',B{i},' ...']) 
end
%if meteorological  data is available
if status==0
myURL=['https://www.ndbc.noaa.gov/view_text_file.php?filename=',B{i},'c',num2str(yr),'.txt.gz&dir=data/historical/cwind/'];
[str,status] = urlread(myURL);
if status==1
    n=n+1;
urlwrite(myURL,[B{i},'c',num2str(yr),'.txt']);
XY2(n,1)=X(i);
XY2(n,2)=Y(i);
II2(n,1)=i;
disp(['Downloading NDBC#',B{i},' ...']) 
end
end
  

end
disp(['Total number of avaiable data = ',num2str(n+m)])
disp('Finished.')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot the buoy locations
load coast


%%
width=1200;  % Width of figure for movie [pixels]
height=700;  % Height of figure of movie [pixels]
left=700;     % Left margin between figure and screen edge [pixels]
bottom=200;  % Bottom margin between figure and screen edge [pixels]


figure
set(gcf,'Position', [left bottom width height]);
plot(long,lat);
hold on
p1=scatter(X,Y,'xk');
hold on
pp=plot([Lon_min Lon_max Lon_max Lon_min Lon_min],[Lat_min Lat_min Lat_max Lat_max Lat_min],'-m');

hold on
if m~=0 & n~=0
p2=scatter(XY1(:,1),XY1(:,2),'or','filled');
hold on
p3=scatter(XY2(:,1),XY2(:,2),'og','filled');
legend([p1,p2,p3,pp],'All','Standard Meteorological','Continuous Wind','Bounding Box');
end
if m~=0 & n==0
p2=scatter(XY1(:,1),XY1(:,2),'or','filled');
legend([p1,p2,pp],'All','Standard Meteorological','Bounding Box');
end

set(gca,'xtick',[-135:45:135],'xticklabel',{'135^{\circ}W','90^{\circ}W','45^{\circ}W','0^{\circ}','45^{\circ}E','90^{\circ}E','135^{\circ}E'});

set(gca,'ytick',[-90:30:90],'yticklabel',{'90^{\circ}S','60^{\circ}S','30^{\circ}S','0^{\circ}','30^{\circ}N','60^{\circ}N','90^{\circ}N'});

xlim([-180 180])
ylim([-90 90])
 %ylabel('latitude [ deg ]');
 %xlabel('Longitude [ deg ]');
