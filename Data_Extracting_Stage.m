function [a1,ou] = Data_Extracting_Stage(vid)

addpath('subfile\');

reader = vision.VideoFileReader('myStego.avi');
% obj.maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
% obj.videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);
detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 415, 'MinimumBackgroundRatio', 0.7);
blob = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea',400);
vid_frame = vision.VideoPlayer('Position', [256,256,256,256]);
vid_mask = vision.VideoPlayer('Position', [256,256,256,256]);
ii = 1;jj = 1;
kalmanFilter = [];
isTrackInitialized = false; 
  while ~isDone(reader)
    frame  = reader.step();
    fgMask = detector.step(frame);
    mask = imopen(fgMask, strel('rectangle', [3,3]));
    mask = imclose(mask, strel('rectangle', [15, 15]));
    mask = imfill(mask, 'holes');
    [~,centroid,bbox] = blob.step(fgMask);
    arr = [];
    arr = bbox;
    a1{ii,1} = arr;
    ii = ii+1;
    [~,centroids,bboxs] = blob.step(mask);
    % draw bounding boxes around cars
    out = insertShape(frame, 'Rectangle', bbox, 'Color', 'blue');
    out1 = insertShape(double(mask),'Rectangle',bboxs,'Color','green');
    % view results in the video player
    step(vid_frame, out); 
    step(vid_mask,out1);
    isObjectDetected = size(bbox, 1) > 0;
    
% % % % % % % % % % % % % % % % % % %     
     if ~isTrackInitialized
     if isObjectDetected % First detection.
       kalmanFilter = configureKalmanFilter('ConstantAcceleration', ...
         bbox(1,:), [1 1 1]*1e5, [25, 10, 10], 25);
       isTrackInitialized = true;
     end
     label = ''; 
     cc = []; % initialize annotation properties
   else  % A track was initialized and therefore Kalman filter exists
     if isObjectDetected % Object was detected
           %Reduce the measurement noise by calling predict, then correct
       predict(kalmanFilter);
       trackedLocation = correct(kalmanFilter, bbox(1,:));
      label = 'Predicted';
     else % Object is missing
       trackedLocation = predict(kalmanFilter);  % Predict object location
       label = 'Predicted';
     end
     cc = [trackedLocation];
   end

%    colorImage = insertObjectAnnotation(double(mask), 'rectangle', ...
%   cc, label, 'Color', 'red'); % mark the tracked object
%    step(vid_mask, colorImage);    % play video
%    
% Background Subtraction
    ou{jj,:} = out - out1;
    jj = jj + 1;
  end
  release(vid_frame);
  release(vid_mask);
  release(reader);

%%   KalmanFIlter
% kalmanFilter = configureKalmanFilter('ConstantAcceleration',...
%                   bbox(1,:), [1 1 1]*1e5, [25, 10, 10], 25);
% predict(kalmanFilter);
% trackedLocation = correct(kalmanFilter, bbox(1,:));
% label = 'Predicted';
%  object = insertObjectAnnotation(frame,'rectangle',...
%                 trackedLocation,label,'Color','red');
