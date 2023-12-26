% Create the Markov chain object and simulate the road conditions

open_system('LaneMaintainSystem.slx')
load_system('AdvisoryControl.slx');

numSamples = 100;
P = [0.6 0.4; 0.85 0.15];
mc = dtmc(P);
roadConditions = simulate(mc, numSamples);
roadConditions = roadConditions(2:end); 

collisions = NaN(numSamples, 1); % 0 = No collision, 1 = collision
switchCount_lcw = 0;
switchCount_hcw = 0;

Hr_lcw = normrnd(61, 14, 1, numSamples);
Rr_lcw = normrnd(17, 8, 1, numSamples);
Rq_lcw = Hr_lcw./Rr_lcw;
Tr_lcw = 0.01*Rq_lcw;

Hr_hcw = normrnd(92, 23, 1, numSamples);
Rr_hcw = normrnd(26, 16, 1, numSamples);
Rq_hcw = Hr_hcw./Rr_hcw;
Tr_hcw = 0.01*Rq_hcw;

decelLim_lcw = -200;
decelLim_hcw = -150;
gain_lcw = 80000;
gain_hcw = 90000;
speeds = randi([20,60],1,numSamples);


for i = 1:numSamples
    curr_speed = speeds(i);
    if roadConditions(i)==1
        disp("Speed = " + curr_speed);

        [A,B,C,D,Kess, Kr, Ke, uD] = designControl(secureRand(),gain_lcw);
        set_param('LaneMaintainSystem/VehicleKinematics/Saturation','LowerLimit',num2str(decelLim_lcw))
        set_param('LaneMaintainSystem/VehicleKinematics/vx','InitialCondition',num2str(curr_speed))

        simModel_lcw = sim('LaneMaintainSystem.slx');
        lastDistance_lcw = simModel_lcw.sx1.Data(end);
        for t = 1:length(simModel_lcw.sx1.Time)
            distance = simModel_lcw.sx1.Data(t);
            if distance > 0
                lastTime_lcw = simModel_lcw.sx1.Time(t);
                break; % Exit the loop as soon as distance exceeds 0
            end
        end


        % Importing the VehicleModelOnly.slx file to calculate the Action Time (Ta)
        % LCW 
        set_param('AdvisoryControl/Step', 'Time', num2str(Tr_lcw(i)));
        set_param('AdvisoryControl/Step', 'After', num2str(decelLim_lcw*1.1));
        simModel_new_lcw = sim('AdvisoryControl.slx');
        Ta_lcw = simModel_new_lcw.sx1.Time(end);

        h_stop_lcw = Ta_lcw + Tr_lcw(i);
        disp("H stop for LCW is " + h_stop_lcw);

        if lastDistance_lcw >= 0
            if h_stop_lcw < lastTime_lcw 
            disp("No Collision")
            switchCount_lcw = switchCount_lcw+1;
            collisions(i) = 0;
            else
                collisions(i) = 1;
                disp("Collision")
            end
        else
            collisions(i) = 0;
            disp("No Collision")
        end
    else
        disp("Speed = " + curr_speed);

        [A,B,C,D,Kess, Kr, Ke, uD] = designControl(secureRand(),gain_hcw);
        set_param('LaneMaintainSystem/VehicleKinematics/Saturation','LowerLimit',num2str(decelLim_hcw))
        set_param('LaneMaintainSystem/VehicleKinematics/vx','InitialCondition',num2str(curr_speed))

        simModel_hcw = sim('LaneMaintainSystem.slx');
        lastDistance_hcw = simModel_hcw.sx1.Data(end);
        for t = 1:length(simModel_hcw.sx1.Time)
            distance = simModel_hcw.sx1.Data(t);
            if distance > 0
                lastTime_hcw = simModel_hcw.sx1.Time(t);
                break;
            end
        end


        % Importing the VehicleModelOnly.slx file to calculate the Action Time (Ta)
        % LCW
        set_param('AdvisoryControl/Step', 'Time', num2str(Tr_hcw(i)));
        set_param('AdvisoryControl/Step', 'After', num2str(decelLim_hcw*1.1));
        simModel_new_hcw = sim('AdvisoryControl.slx');
        Ta_hcw = simModel_new_hcw.sx1.Time(end);

        h_stop_hcw = Ta_hcw + Tr_hcw(i);
        disp("H stop for HCW is " + h_stop_hcw);

        if lastDistance_hcw >= 0
            if h_stop_hcw < lastTime_hcw
            disp("No Collision")
            switchCount_hcw = switchCount_hcw+1;
            collisions(i) = 0;
            else
                collisions(i) = 1;
                disp("Collision")
            end
        else
            collisions(i) = 0;
            disp("No Collision")
        end
    end
end

% ----------------------------------------------------------------------------------------------------------------------------------

minCollision = sum(collisions == 1);
constFactor = 0;

factor = 0.01;

while factor <= 0.1
    collisionCounter = 0;
    for i = 1:numSamples
        curr_speed = speeds(i);
        if roadConditions(i)==1
            disp("Speed = " + curr_speed);

            [A,B,C,D,Kess, Kr, Ke, uD] = designControl(secureRand(),gain_lcw);
            set_param('LaneMaintainSystem/VehicleKinematics/Saturation','LowerLimit',num2str(decelLim_lcw))
            set_param('LaneMaintainSystem/VehicleKinematics/vx','InitialCondition',num2str(curr_speed))

            simModel_lcw = sim('LaneMaintainSystem.slx');
            lastDistance = simModel_lcw.sx1.Data(end);
            for t = 1:length(simModel_lcw.sx1.Time)
                distance = simModel_lcw.sx1.Data(t);
                if distance > 0
                    lastTime = simModel_lcw.sx1.Time(t);
                    break; % Exit the loop as soon as distance exceeds 0
                end
            end


            % Importing the VehicleModelOnly.slx file to calculate the Action Time (Ta)
            % LCW

            Tr = Rq_lcw(i) * factor;
            set_param('AdvisoryControl/Step', 'Time', num2str(Tr));
            set_param('AdvisoryControl/Step', 'After', num2str(decelLim_lcw*1.1));
            simModel_new_lcw = sim('AdvisoryControl.slx');
            Ta = simModel_new_lcw.sx1.Time(end);

            hStop = Ta + Tr;
            disp("H stop for LCW is " + hStop);

            if lastDistance >= 0
                if hStop < lastTime 
                disp("No Collision happened")
                else
                    collisionCounter = collisionCounter+1;
                    disp("Collision Happened")
                end
            else
                disp("No Collision happened")
            end
        else
            disp("Speed = " + curr_speed);

            [A,B,C,D,Kess, Kr, Ke, uD] = designControl(secureRand(),gain_hcw);
            set_param('LaneMaintainSystem/VehicleKinematics/Saturation','LowerLimit',num2str(decelLim_hcw))
            set_param('LaneMaintainSystem/VehicleKinematics/vx','InitialCondition',num2str(curr_speed))

            simModel_hcw = sim('LaneMaintainSystem.slx');
            lastDistance = simModel_hcw.sx1.Data(end);
            for t = 1:length(simModel_hcw.sx1.Time)
                distance = simModel_hcw.sx1.Data(t);
                if distance > 0
                    lastTime = simModel_hcw.sx1.Time(t);
                    break;
                end
            end


            % Importing the VehicleModelOnly.slx file to calculate the Action Time (Ta)
            % LCW

            Tr = Rq_hcw(i) * factor;
            set_param('AdvisoryControl/Step', 'Time', num2str(Tr));
            set_param('AdvisoryControl/Step', 'After', num2str(decelLim_hcw*1.1));
            simModel_new_hcw = sim('AdvisoryControl.slx');
            Ta = simModel_new_hcw.sx1.Time(end);

            hStop = Ta + Tr;
            disp("H stop for HCW is " + hStop);

            if lastDistance >= 0
                if hStop < lastTime
                    disp("No Collision happened")
                else
                    collisionCounter = collisionCounter + 1;
                    disp("Collision happened")
                end
            else
                disp("No Collision happened")
            end
        end
    end

    if collisionCounter<minCollision
        minCollision = collisionCounter;
        constFactor = factor;
    end
    collisionCounter = 0;
    factor = factor + 0.01;
end




