% GUI for Action Potentioal Duration analysis
% Inputs: 
% apdMapGroup -- pannel to draw on
% handles     -- rhythm handles
% f           -- figure of the main rhythm window
% 
% by Roman Pryamonosov, Andrey Pikunov, Roman Syunyaev, and Alexander Zolotarev 
function GUI_NADH(NADHGroup, handles, f)
handles.objectToDrawOn = NADHGroup;

font_size = 9;
pos_bottom = 1; % initial position (top)
element_height = 0.065; % default, you may adjust it
% We will move from top to bottom and create buttons and labels

%% Line 1
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.7;
starttime_NADHmap_text = uicontrol('Parent',NADHGroup, ...
                                  'Style','text',...
                                  'FontSize',font_size, ...
                                  'String','Start Time (s)',...
                                  'Units','normalized',...
                                  'Position',[pos_left, pos_bottom, element_width, element_height]);

pos_left = 0.7;
element_width = 1 - pos_left;                           
starttimeNADHmap_edit = uicontrol('Parent',NADHGroup,...
                                       'Style','edit', ...
                                       'FontSize',font_size, ...
                                       'String', handles.apd_alternance_start_time,...
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height],...
                                       'Callback', @startTime_callback);

%% Line 2
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.7;
endtime_NADHmap_text   = uicontrol('Parent',NADHGroup, ...
                                       'Style','text',...
                                       'FontSize',font_size,...
                                       'String','End Time (s)',...
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height]);
pos_left = 0.7;
element_width = 1 - pos_left;
endtimeNADHmap_edit   = uicontrol('Parent',NADHGroup,...
                                       'Style','edit',...
                                       'FontSize',font_size,...
                                       'String', handles.apd_alternance_end_time, ...
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height], ...
                                       'Callback', @endTime_callback);


%% Line 6
pos_left = 0;
pos_bottom = pos_bottom - 2*element_height;
element_width = 0.75;
create_Vmamap_button  = uicontrol('Parent',NADHGroup,...
                                       'Style','pushbutton',...
                                       'FontSize',font_size,...
                                       'String','Diff Map 1',...
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height],...
                                       'Callback',@createNADHdiffmap1_button_callback);
                                   

pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.75;
create_Vmamap_button  = uicontrol('Parent',NADHGroup,...
                                       'Style','pushbutton',...
                                       'FontSize',font_size,...
                                       'String','Diff Map 2',...
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height],...
                                       'Callback',@createNADHdiffmap2_button_callback);

 
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.75;
create_Vmamap_button  = uicontrol('Parent',NADHGroup,...
                                       'Style','pushbutton',...
                                       'FontSize',font_size,...
                                       'String','Calc Difference',...
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height],...
                                       'Callback',@createCalcDifference_button_callback);

pos_left = 0;
pos_bottom = 0 + element_height;
element_width = 0.7;
create_NADHmap_button  = uicontrol('Parent',NADHGroup,...
                                       'Style','pushbutton',...
                                       'FontSize',font_size,...
                                       'String','Regional Map',...
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height],...
                                       'Callback',@createNADHmap_callback);                           
                            

                                   
                                   
                                   
% Line 7
pos_left = 0;
pos_bottom = 0;
element_width = 0.7;
create_NADHmap_global_button = uicontrol('Parent',NADHGroup,'Style','pushbutton',...
                                'FontSize',font_size,...
                                'String','Global NADH Map',...
                                'Units','normalized',...
                                'Position',[pos_left, pos_bottom, element_width, element_height],...
                                'Callback',{@createNADHglobalmap_callback});

%%                             
export_icon = imread('icon.png');
export_icon = imresize(export_icon, [20, 20]); 

pos_left = 0.7;
element_width = 1 - pos_left;
button_height = 2 * element_height;
export_button = uicontrol('Parent',NADHGroup,'Style','pushbutton',...
                        'Units','normalized',...
                        'Position',[pos_left, pos_bottom, element_width, button_height],...
                        'Callback',{@export_button_callback});
set(export_button,'CData',export_icon);

%%
% Save handles in figure with handle f.
guidata(NADHGroup, handles);
startTime_callback(starttimeNADHmap_edit);

% callback functions
 %% NADH MAP
 function startTime_callback(source,~)
        val_start = str2double(get(source,'String'));
        val_end = str2double(get(endtimeNADHmap_edit,'String'));
        if (val_start < 0)
            set(source,'String', 0);
            val_start = 0;
        end
        if (val_start >= val_end)
            set(source,'String', num2str(val_start));
            val_end = val_start + 0.01;
            set(endtimeNADHmap_edit,'String', num2str(val_end));
            set(source,'String', num2str(val_start));
        end
        drawTimeLines(val_start, val_end, handles, f);
    end

    function endTime_callback(source,~)
        val_start = str2double(get(starttimeNADHmap_edit,'String'));
        val_end = str2double(get(source,'String'));
        if (val_start >= val_end)
            val_start = val_end - 0.01;
            set(starttimeNADHmap_edit,'String', num2str(val_start));
        end
        drawTimeLines(val_start, val_end, handles, f);
    end 

    function drawTimeLines(val_start, val_end, handles, f)
        if val_start >= 0 && val_start <= handles.time(end)
            if val_end >= 0 && val_end <= handles.time(end)
                % set boundaries to draw time lines
                playTimeA = [(handles.time(handles.frame)-handles.starttime)*handles.timeScale (handles.time(handles.frame)-handles.starttime)*handles.timeScale];
                startLineA = [(val_start-handles.starttime)*handles.timeScale (val_start-handles.starttime)*handles.timeScale]; 
                endLineA = [(val_end-handles.starttime)*handles.timeScale (val_end-handles.starttime)*handles.timeScale];
                if (handles.bounds(handles.activeScreenNo) == 0)
                    set(f,'CurrentAxes',handles.sweepBar)
                    pointB = [0 1]; cla;
                    plot(startLineA, pointB, 'g', 'Parent', handles.sweepBar)
                    hold on
                    axis([0 handles.time(end) 0 1])
                    plot(playTimeA, pointB, 'r', 'Parent', handles.sweepBar)
                    hold on
                    plot(endLineA, pointB, '-g','Parent',handles.sweepBar)
                    hold off; axis off
                    hold off 
                else
                    hold on
                    for i_group=1:5
                        set(f,'CurrentAxes',handles.signalGroup(i_group).sweepBar);
                        pointB = [0 1]; cla;
                        plot(startLineA, pointB, 'g', 'Parent', handles.signalGroup(i_group).sweepBar)
                        hold on;
                        plot(playTimeA, pointB, 'r', 'Parent', handles.signalGroup(i_group).sweepBar)
                        hold on;
                        plot(endLineA, pointB, '-g','Parent', handles.signalGroup(i_group).sweepBar)
                        axis([0 handles.time(end) 0 1])
                        hold off; axis off;
                        hold off;
                    end
                    
                end
            else
                error = 'The END TIME must be greater than %d and less than %.3f.';
                msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
                set(endtimeNADHmap_edit,'String',max(handles.time))
            end
        else
            error = 'The START TIME must be greater than %d and less than %.3f.';
            msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
            set(starttimeNADHmap_edit,'String',0)
        end
    end


%%Create Difference map
function createNADHdiffmap1_button_callback(~,~)
        global NADH1
        % get the bounds of the activation window
        a_start = str2double(get(starttimeNADHmap_edit,'String'));
        a_end = str2double(get(endtimeNADHmap_edit,'String'));
        drawTimeLines(a_start, a_end, handles, f);
        handles.a_start = a_start;
        handles.a_end = a_end;
        Rect = getrect(handles.activeScreen);
        rect=round(abs(Rect));
        axes(handles.activeCamData.screen)
        gg=msgbox('Building  NADH Map...');
        NADHMap(handles.activeCamData.cmosData,...
             handles.a_start,handles.a_end,rect,...
             handles.activeCamData.Fs,handles.activeCamData.cmap, handles.activeCamData.screen, handles);
        handles.activeCamData.drawMap = 1;
        close(gg)
        handles.NADH1 = handles.activeCamData.saveData;
        
    end

    function createNADHdiffmap2_button_callback(~,~)
        global NADH2;
        % get the bounds of the activation window
        a_start = str2double(get(starttimeNADHmap_edit,'String'));
        a_end = str2double(get(endtimeNADHmap_edit,'String'));
        drawTimeLines(a_start, a_end, handles, f);
        handles.a_start = a_start;
        handles.a_end = a_end;
        Rect = getrect(handles.activeScreen);
        rect=round(abs(Rect));
        axes(handles.activeCamData.screen)
        gg=msgbox('Building  NADH Map...');
        NADHMap(handles.activeCamData.cmosData,...
             handles.a_start,handles.a_end,rect,...
             handles.activeCamData.Fs,handles.activeCamData.cmap, handles.activeCamData.screen, handles);
        handles.activeCamData.drawMap = 1;
        close(gg)
        handles.NADH2 = handles.activeCamData.saveData;
    end


    function createCalcDifference_button_callback(~,~)
        NADH1 = handles.NADH1;
        NADH2 = handles.NADH2;
        AvgNADH1 = nanmean(NADH1,1);
        AvgNADH1 = nanmean(AvgNADH1)
        AvgNADH2 = nanmean(NADH2,1);
        AvgNADH2 = nanmean(AvgNADH2)
        NADH1(NADH1(:)<0.9*AvgNADH1)=0;
        NADH1(NADH1(:)>1.6*AvgNADH1)=0;
        NADH2(NADH2(:)<0.9*AvgNADH2)=0;
        NADH2(NADH2(:)>1.6*AvgNADH2)=0;
        NADHDiff = NADH2 - AvgNADH1;
%         NADHDiff(NADHDiff>450)=NaN;
%         NADHDiff(NADHDiff<-450)=NaN;
        
        figure();
%         colormap(handles.activeCamData.cmap);
        colormap([1 1 1; winter])
        imagesc(NADHDiff);
        caxis([-100 500])
        NADHDiff_min = min(NADHDiff(:));
        NADHDiff_max = max(NADHDiff(:));
%         colorbar('eastoutside','ylim',[NADHDiff_min NADHDiff_max])
        colorbar('eastoutside','ylim',[0 450])
        
    end



 %% Button to create Global NADH map
    function createNADHglobalmap_callback(~,~)
              
        a_start = str2double(get(starttimeNADHmap_edit,'String'));
        a_end = str2double(get(endtimeNADHmap_edit,'String'));
        
        handles.a_start = a_start;
        handles.a_end = a_end;
        
        rect = [1,1,...
                       size(handles.activeCamData.cmosData, 1)-1,...
                       size(handles.activeCamData.cmosData, 2)-1];
                   
        gg=msgbox('Creating global NADH Map ...');           
        
        NADHMap(handles.activeCamData.cmosData,a_start,a_end,rect,handles.activeCamData.Fs,handles.activeCamData.cmap,handles.activeCamData.screen, handles);
           
        handles.activeCamData.drawMap = 1;
        close(gg)
    end


 %% Button to Calculate Regional NADH
    function createNADHmap_callback(~,~)
        
        a_start = str2double(get(starttimeNADHmap_edit,'String'));
        a_end = str2double(get(endtimeNADHmap_edit,'String'));
        
        handles.a_start = a_start;
        handles.a_end = a_end;
        Rect = getrect(handles.activeScreen);
        rect=round(abs(Rect));
        
        gg=msgbox('Building  Intensity Map...');
              
        NADHMap(handles.activeCamData.cmosData,a_start,a_end,rect,handles.activeCamData.Fs,handles.activeCamData.cmap,handles.activeCamData.screen, handles);
           
        handles.activeCamData.drawMap = 1;
        close(gg)
    end



 
 %% Export picture from the screen
    function export_button_callback(~,~)  
       if isempty(handles.activeCamData.saveData)
           error = 'ExportedData must exist! Function cancelled.';
           msgbox(error,'Incorrect Input','Error');
           return
       else
           NADHMap = handles.activeCamData.saveData;
           figure;
           imagesc (NADHMap, 'AlphaData', ~isnan(NADHMap));
           set(gca, 'Color', 'w');
           NADH_min = prctile(NADHMap(isfinite(NADHMap)), 1);
           NADH_max = prctile(NADHMap(isfinite(NADHMap)), 99);
           caxis([NADH_min NADH_max]);
           caxis([700 1250])
           colormap([1 1 1; winter]);
           cb = colorbar;
           cb_label = sprintf('NADH%d (Fluorescence Intensity)');
           ylabel(cb, cb_label);
       end
    end
end
