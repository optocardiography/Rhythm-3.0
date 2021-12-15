function [actMap1] = NADHMap(data,...
                            stat,endp,...
                            rect,... % rectangle of ROI coords
                            Fs,cmap,...
                            movie_scrn, handles)
%% aMap is the central function for creating conduction velocity maps
% [actMap1] = aMap(data,stat,endp,Fs,bg) calculates the activation map
% for a single action potential upstroke.

% INPUTS
% data = cmos data (voltage, calcium, etc.) from the micam ultima system.
% 
% stat = start of analysis (in msec)
%
% endp = end of analysis (in msec)
%
% Fs = sampling frequency
%
% bg = black and white background image from the CMOS camera.  This is a
% 100X100 pixel image from the micam ultima system. bg is stored in the
% handles structure handles.bg.
%
% cmap = a colormap input that facilites the potential inversion of the
% colormap. cmap is stored in the handles structure as handles.cmap.
%
%
% OUTPUT
% actMap1 = activation map
%
% METHOD
% An activation map is calculated by finding the time of the maximum derivative 
% of each pixel in the specified time-windowed data.
%
% RELEASE VERSION 1.0.1
%
% AUTHOR: Qing Lou, Jacob Laughner (jacoblaughner@gmail.com)
%
%
% MODIFICATION LOG:
%
% Jan. 26, 2015 - The input cmap was added to input the colormap and code
% was added at the end of the function to set the colormap to the user
% determined values. In this case the most immediate purpose is to
% facilitate inversion of the default colormap.
%
% Email optocardiography@gmail.com for any questions or concerns.
% Refer to efimovlab.org for more information.



%% Code

if stat == 0
    stat = 1; % Subscript indices must either be real positive integers or logicals
end
% Create initial variables
stat=round(stat*Fs);
endp=round(endp*Fs);

% Code not used in current version %
% % actMap = zeros(size(data,1),size(data,2));
% % mask2 = zeros(size(data,1),size(data,2));

                % identify channels that have been zero-ed out due to noise
            if size(data,3) == 1
                temp = data(:,stat:endp);       % Windowed signal
                mask = max(temp,[],2) < 0;      % Generate mask
            else
                temp = data(:,:,stat:endp);     % Windowed signal
                mask = max(temp,[],3) < 0;      % Generate mask
            end


            % Find Intensity average over time
            temp2 = abs(nanmean(temp,3)); 
            

            % Activation Map Matrix
            actMap1 = temp2.*mask;

            
            mask_ROI = zeros(size(mask));
            mask_ROI(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3)) = 1;
            
            actMap1(mask_ROI == 0) = nan;
            actMap1(actMap1 == 0) = nan;

            

            % Plot Map
            if size(data,3) ~= 1
                handles.activeCamData.saveData = actMap1;

                G = handles.activeCamData.bgRGB;
                N = size(G, 1);
                M = size(G, 2);
                
%                 AvgNADH1 = nanmean(actMap1,1);
%                 AvgNADH1 = nanmean(AvgNADH1);
%                 actMap1(actMap1(:)<0.9*AvgNADH1)=0;
%                 actMap1(actMap1(:)>1.6*AvgNADH1)=0;

                f = figure('visible', 'off');
                colormap(winter);
                imagesc(flipud(actMap1));
                caxis([500 1200])
                frame = getframe();
                close(f);
                J = imresize(frame.cdata, [N, M],'nearest');
                J = double(J) / 255.;
                J = flipud(J);

                mask_ROI=repmat(mask_ROI,[1 1 3]);
                I = J .* mask_ROI + G .* (1 - mask_ROI);

                cla(handles.activeCamData.screen);
                image(I,'Parent',handles.activeCamData.screen);


                set(handles.activeCamData.screen,'YDir','reverse');
                set(handles.activeCamData.screen,'YTick',[],'XTick',[]);
            end

            %% Calculating statistics
            NADH_mean=nanmean(actMap1(:));
            disp(['The average NADH in the region is ' num2str(NADH_mean)])
            NADH_std=nanstd(actMap1(:));
            disp(['The standard deviation of NADH in the region is ' num2str(NADH_std)])
            NADH_median=nanmedian(actMap1(:));
            disp(['The median NADH in the region is ' num2str(NADH_median)])

            handles.activeCamData.meanresults           = sprintf('Mean: %0.3f',NADH_mean);
            handles.activeCamData.medianresults         = sprintf('Median: %0.3f',NADH_median);
            handles.activeCamData.SDresults             = sprintf('S.D.: %0.3f',NADH_std);
            handles.activeCamData.num_membersresults    = sprintf('');
            handles.activeCamData.angleresults          = sprintf('');

            set(handles.meanresults,'String',handles.activeCamData.meanresults);
            set(handles.medianresults,'String',handles.activeCamData.medianresults);
            set(handles.SDresults,'String',handles.activeCamData.SDresults);
            set(handles.num_members_results,'String',handles.activeCamData.num_membersresults);
            set(handles.angleresults,'String',handles.activeCamData.angleresults);
end




