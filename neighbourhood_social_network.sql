-- phpMyAdmin SQL Dump
-- version 4.9.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 13, 2019 at 11:42 PM
-- Server version: 10.4.8-MariaDB
-- PHP Version: 7.3.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `neighbourhood_social_network`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AdminstratorBan` (IN `member_id` INT)  BEGIN
	update nsnMember set isDeleted=1 where nsnmember.id=member_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AdminstratorUnBan` (IN `member_id` INT)  BEGIN
	update nsnMember set isDeleted=0 where nsnmember.id=member_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `areFriends` (IN `f1` INT, IN `f2` INT, OUT `checkBit` BIT)  BEGIN
if (exists (select * from Adds,NSNMember AS m1, NSNMember AS m2 where ((m1.id = f1 AND m2.id = f2 AND m1.isDeleted = 0 AND m2.isDeleted = 0) AND ((adds.adder_id=f1 and adds.added_id=f2) or (adds.adder_id=f2 and adds.added_id=f1)) and adds.isDeleted=0 and adds.add_status="accepted")))then
set checkBit =1;
else
set checkBit =0;

end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `areNeighbours` (IN `n1` INT, IN `n2` INT, OUT `checkBit` BIT)  BEGIN
if (exists (select * from nsnmember as mem1 ,nsnmember as mem2 where (mem1.id=n1 and mem2.id=n2 and mem1.street_name=mem2.street_name and mem1.isDeleted = 0 and mem2.isDeleted = 0)))then
set checkBit =1;
else
set checkBit =0;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `assignGroupAdmin` (IN `admin_id` INT, IN `member_id` INT, IN `group_id` INT, OUT `checkBIT` BIT)  BEGIN

	IF(EXISTS(SELECT * FROM joins AS j WHERE j.member_id = admin_id AND j.group_id = group_id AND j.is_admin = 1 AND j.isDeleted = 0 AND j.join_status = 'accepted'))
		THEN
			IF(EXISTS(SELECT * FROM joins AS j WHERE j.member_id = member_id AND j.join_status = 'accepted' AND j.isDeleted = 0 AND j.group_id = group_id AND j.is_admin <> 1))
				THEN
					SET checkBIT = 0;
                    UPDATE joins as j
                    SET j.is_admin = 1
                    WHERE(j.member_id = member_id AND j.join_status = 'accepted' AND j.isDeleted = 0 AND j.group_id = group_id AND j.is_admin <> 1);
				ELSE
					IF(EXISTS(SELECT * FROM joins AS j WHERE j.member_id = member_id AND j.join_status = 'accepted' AND j.isDeleted = 0 AND j.group_id = group_id AND j.is_admin = 1))
						THEN
							SET checkBIT = 0;
							UPDATE joins as j
							SET j.is_admin = 0
							WHERE j.member_id = member_id AND j.join_status = 'accepted' AND j.isDeleted = 0 AND j.group_id = group_id AND j.is_admin = 1; -- sarah checked
                ELSE        
					SET checkBIT = 1;
				END IF;
		END IF;
        END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `blockNeighbour` (IN `subject_id` INT, IN `object_id` INT, OUT `errorBit` BIT)  BEGIN
	call areNeighbours(subject_id,object_id,@c);
	IF(@c=1)then
		set errorBit=0;
		if( not exists (select * from blocks where blocker_id=subject_id and blocked_id=object_id))THEN
			SET @t = now();
            INSERT INTO blocks(blocker_id, blocked_id,blocked_time) VALUES (subject_id, object_id,@t); 
			update adds set add_status = "rejected" where  adds.adder_id =subject_id AND adds.added_id = object_id ; 
			update adds set add_status = "rejected" where  adds.adder_id =object_id AND adds.added_id = subject_id ; 
		ELSE
			Delete from blocks where blocker_id=subject_id and blocked_id=object_id;
		END IF;
		set errorBit=1;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `calculateRate` (IN `member_id` INT, OUT `rate` INT)  BEGIN
select avg(rate_value) as val
FROM rates 
WHERE rates.rated_id = member_id;
-- select rate;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cancelInvitation` (IN `member_id` INT, IN `event_id` INT, IN `creator_id` INT, OUT `errorBit` BIT)  BEGIN
if( exists(select * from private_event where private_event.event_id = event_id) -- lazm yb2a private event
AND ((select organizer_id  from NSN_event as mem where mem.event_id = event_id) = creator_id) -- lazm el by7awl y8yr yb2a howa el creator
AND (exists(select * from InvitedToPrivateEvent as e where e.event_id = event_id AND e.invited_id = member_id AND e.invitation_status = 'pending' ))) then -- lazm yb2a f el event
delete from InvitedToPrivateEvent
where InvitedToPrivateEvent.event_id = event_id AND InvitedToPrivateEvent.invited_id = member_id ;
set errorBit = 0;
else
set errorBit = 1;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `commentOnNews` (IN `member_ID` INT, IN `comment_content` TEXT, IN `post_ID` INT, OUT `errorBit` BIT)  BEGIN
	
	--  1- check if the owner of the post is a neighbour to the member trying to comment
    -- 2- member can comment either if the group is null(post doesnot belong to a group ) or if the the commenter and the post belong to the same group
    IF(
    exists (select * from nsnmember as mem1 ,nsnmember as mem2,post where (post.isDeleted = 0 and mem1.isDeleted = 0 and mem2.isDeleted = 0 and post.isDeleted = 0 and post.post_id=post_ID and mem1.id=post.uploader_id and mem2.id=member_ID and mem1.street_name=mem2.street_name)
			and(
				(post.group_id is null) 
                or
                ( exists (select * from joins where (joins.member_id=member_ID and joins.group_id=post.group_id) ))
                )
			)
		)THEN 
    Insert into nsncomment(comment_contenet, comment_time, post_id, commenter_id)values(comment_content,now() ,post_ID,member_ID);
        set errorBit=0;
	ELSE
		set errorBit=1;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createGroup` (IN `member_id` INT, IN `group_name` VARCHAR(30), OUT `checkBIT` BIT)  BEGIN
	IF (EXISTS(SELECT * FROM NSNMember AS MEM WHERE MEM.id = member_id AND MEM.isDeleted = 0))
		THEN
			SET @t = now();
			INSERT INTO NSNgroup (group_name,creator_id,creation_date) VALUES (group_name,member_id,@t);
            SET checkBIT = 0;
            SELECT MAX(group_id) INTO @temp_id FROM NSNgroup WHERE NSNgroup.creator_id = member_id AND NSNgroup.creation_date = @t;
            INSERT INTO joins (group_id,member_id,isDeleted,join_status,is_admin) VALUES (@temp_id,member_id,0,'accepted',1);
		ELSE
			SET checkBIT = 1;
		END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteCommentOnNews` (IN `member_ID` INT, IN `_time` DATETIME, IN `post_ID` INT, OUT `errorBit` BIT)  BEGIN
	
	--  1- check if the owner of the post is a neighbour to the member trying to comment
    -- 2- member can comment either if the group is null(post doesnot belong to a group ) or if the the commenter and the post belong to the same group
    IF(
    exists (select * from nsnmember as mem1 ,nsnmember as mem2,post where (post.isDeleted = 0 and mem1.isDeleted = 0 and mem2.isDeleted = 0 and post.post_id=post_ID and mem1.id=post.uploader_id and mem2.id=member_ID and mem1.street_name=mem2.street_name)
			and(
				(post.group_id is null) 
                or
                ( exists (select * from joins where (joins.member_id=member_ID and joins.group_id=post.group_id) ))
                )
			)
		)THEN 
        IF ( exists(select * from nsncomment where nsncomment.isDeleted = 0 and nsncomment.post_id=post_id and nsncomment.commenter_id=member_ID and nsncomment.comment_time=_time)) then
			update nsncomment set isDeleted=1 where  nsncomment.post_id=post_id and nsncomment.commenter_id=member_ID and nsncomment.comment_time=_time;
			set errorBit=0;
        ELSE
        		set errorBit=1;
        END IF;
	ELSE
		set errorBit=1;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteGroup` (IN `admin_id` INT, IN `group_id` INT, OUT `checkBIT` BIT)  BEGIN
	IF (EXISTS(SELECT * FROM NSNMember AS MEM WHERE MEM.id= admin_id AND MEM.isDeleted = 0 ))
		THEN
    IF(EXISTS(SELECT * FROM joins AS j WHERE j.member_id = admin_id AND j.group_id = group_id AND j.is_admin = 1 AND j.isDeleted = 0 AND j.join_status = 'accepted'))
		THEN
			SET checkBIT = 0;
			UPDATE NSNgroup
			SET NSNgroup.isDeleted = 1
            WHERE NSNgroup.group_id =group_id ; -- sarah checked
		ELSE
			SET checkBIT = 1;
		END IF;
        END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deletePostNews` (IN `poster_id` INT, IN `post_id` INT, OUT `errorBit` BIT)  BEGIN
	IF( EXISTS(SELECT * FROM post WHERE (post.post_id = post_id and post.uploader_id = poster_id) )) THEN
		UPDATE post set isDeleted = 1 where (post.post_id = post_id and post.uploader_id = poster_id) ;
        set errorBit=0;
	ELSE
		select max(post.group_id) into @g_id from post where post.post_id = post_id;
		CALL isGroupAdmin(poster_id, @g_id,@c);
		IF(@c=1)THEN
			UPDATE post set isDeleted = 1 where (post.post_id = post_id) ;
			set errorBit=0;
		ELSE set errorBit=1;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteRequest` (IN `request_num` INT, IN `editor_id` INT, OUT `error_bit` BIT)  BEGIN
IF EXISTS(SELECT * FROM Supply WHERE Supply.request_num = request_num AND Supply.member_id = editor_id) THEN
UPDATE Supply
SET Supply.isDeleted = 1
WHERE Supply.request_num = request_num;
SET error_bit = 0;
ELSE
SET error_bit = 1;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `filterServiceByDuration` (IN `member_id` INT, IN `search_term` TEXT, IN `start_time` DATETIME, IN `end_time` DATETIME)  BEGIN
SELECT supply_name, supply_description, requested_time, request_status, username, first_name, last_name FROM Supply , nsnmember as mem, service
WHERE supply.isDeleted = 0 AND Supply.request_num = Service.request_num AND request_status = 'pending' AND (Supply.supply_name = search_term OR search_term = '') AND Service.start_time >= start_time AND Service.end_time <= end_time AND mem.id = Supply.member_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getEventInfo` (IN `event_id` INT)  NO SQL
BEGIN
SELECT * FROM nsn_event,nsnmember where nsn_event.organizer_id = nsnmember.id AND nsn_event.event_id=event_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFriendshipStatus` (IN `subjectID` INT, IN `objectID` INT)  NO SQL
BEGIN
call areFriends(subjectID, objectID, @c);
if(@c)THEN set @ans = 'friends';
ELSE
	IF(EXISTS (SELECT * FROM adds WHERE adds.adder_id=subjectID 	AND adds.added_id = objectID ))THEN SET @ans = 'pending_from_me';
	ELSE
		IF(EXISTS (SELECT * FROM adds WHERE adds.adder_id=objectID 			AND adds.added_id = subjectID ))THEN SET @ans = 'pending_to_me';
		ELSE
		SET @ans = 'not_friends';
		END IF;
	END IF;
END IF;
SELECT @ans;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `inviteMember` (IN `member_id` INT, IN `event_id` INT, IN `creator_id` INT, OUT `errorBit` BIT)  BEGIN
CALL areNeighbours(creator_id, member_id, @c);
if( exists(select * from private_event where private_event.event_id = event_id) AND @c 
AND ((select organizer_id  from NSN_event as mem where mem.event_id = event_id) = creator_id) -- lazm el creator yb2a howa el by8yr
AND not exists(select invited_id from InvitedToPrivateEvent as i where i.invited_id = member_id and i.event_id=event_id)) then -- lazm mykonsh invited f el event already
INSERT INTO InvitedToPrivateEvent(invited_id,event_id, invited_time)
VALUES(member_id, event_id, now());
set errorBit = 0;

Else 
if( exists(select * from private_event where private_event.event_id = event_id) AND @c -- lazm yb2a private event -- 
AND ((select organizer_id  from NSN_event as mem where mem.event_id = event_id) = creator_id) -- lazm el creator yb2a howa el by8yr
AND  exists(select invited_id from InvitedToPrivateEvent as i where i.invited_id = member_id AND (i.isDeleted = 1 OR i.invitation_status = 'rejected'))) then -- lazm mykonsh 3ndy f el event already
Update InvitedToPrivateEvent
Set invitation_status = 'pending',
isDeleted =0 
where InvitedToPrivateEvent.event_id = event_id AND InvitedToPrivateEvent.invited_id = member_id ;
set errorBit = 0;

else
set errorBit = 1;
end if;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `inviteToGroup` (IN `admin_id` INT, IN `member_id` INT, IN `group_id` INT, OUT `checkBIT` BIT)  BEGIN
call areNeighbours(admin_id,member_id,@c);
	IF (@c=1) -- check 2no nsnmember
		THEN
		IF(EXISTS(SELECT * FROM joins AS j WHERE j.member_id = admin_id AND j.group_id = group_id AND j.is_admin = 1 AND j.isDeleted = 0 AND j.join_status = 'accepted'))
			THEN
			IF(not EXISTS(SELECT * FROM joins as j  WHERE j.member_id = member_id AND  j.group_id=group_id ))
				THEN 
				INSERT INTO joins (group_id,member_id,join_status) VALUES (group_id,member_id,'pending');
			ELSE
				IF( EXISTS(SELECT * FROM joins as j  WHERE j.member_id = member_id AND  j.group_id=group_id and (j.join_status="rejected" or j.isdeleted=1)))THEN
                update joins as j set j.join_status="pending", j.isDeleted=0 where j.member_id = member_id AND  j.group_id=group_id and (j.join_status="rejected" or j.isdeleted=1);
				END IF;
			END IF;
		END IF;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `isEventOrganizer` (IN `memberID` INT, IN `eventID` INT, OUT `checkBit` BIT)  NO SQL
BEGIN
	IF(not eventID is null) then
		 IF (exists (select * 
         from nsnmember as m,nsn_event as nsne 
         where nsne.event_id = eventID and m.id=memberID and m.isDeleted = 0  and nsne.isDeleted = 0 and nsne.organizer_id=memberID ))then
			SET checkBit =1;
		ELSE
			SET checkBit =0;
		END IF;

	ELSE
		SET checkBit =0;

	END IF;
	select checkBit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `isGroupAdmin` (IN `memberID` INT, IN `groupID` INT, OUT `checkBit` BIT)  BEGIN
	IF(not groupID is null) then
		 IF (exists (select * from joins as g, nsnmember as m,nsngroup as nsng where g.group_id=groupID and m.id=memberID and m.isDeleted = 0 and g.join_status="accepted" and g.isDeleted=0 and g.is_admin=1 and nsng.isDeleted = 0 and g.member_id=memberID))then
			SET checkBit =1;
		ELSE
			SET checkBit =0;
		END IF;

	ELSE
		SET checkBit =0;

	END IF;
    select checkBit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `leaveGroup` (IN `member_id` INT, IN `group_id` INT, OUT `checkBIT` BIT)  BEGIN
	IF (EXISTS(SELECT * FROM NSNMember AS MEM WHERE MEM.id= member_id AND MEM.isDeleted = 0))
		THEN
			IF (EXISTS(SELECT * FROM joins AS j WHERE j.member_id = member_id AND j.join_status = 'accepted' AND j.isDeleted = 0))
				THEN
					SET checkBIT = 0;
					UPDATE joins AS j
					SET j.isDeleted = 1 ,j.is_admin = 0
					WHERE j.member_id = member_id AND j.join_status = 'accepted' AND j.isDeleted = 0 AND j.group_id = group_id;
				ELSE
					SET checkBIT = 1;
			END IF;   
		END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `likeOnNews` (IN `member_ID` INT, IN `post_ID` INT, OUT `errorBit` BIT)  BEGIN
	
	--  1- check if the owner of the post is a neighbour to the member trying to comment
    --  2- member can like either if the group is null(post doesnot belong to a group ) or if the the commenter and the post belong to the same group
    IF(
    exists (select * from nsnmember as mem1 ,nsnmember as mem2,post where (post.isDeleted = 0 and mem1.isDeleted = 0 and mem2.isDeleted = 0 and post.post_id=post_ID and mem1.id=post.uploader_id and mem2.id=member_ID and mem1.street_name=mem2.street_name)
			and(
				(post.group_id is null) 
                or
                ( exists (select * from joins where (joins.member_id=member_ID and joins.group_id=post.group_id) ))
                )
			)
		)THEN 
        -- law mafi4 like ha7oto law fih h4ilo
        IF(not exists(select * from likes where likes.post_id=post_id and likes.member_id=member_ID))then
			Insert into likes( post_id, member_id)values (post_ID,member_ID);
		else
			Delete from likes where likes.post_id=post_id and likes.member_id=member_ID;
		end if;
        set errorBit=0;
	ELSE
		set errorBit=1;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `logIn` (IN `username` VARCHAR(30), IN `user_password` VARCHAR(30), OUT `errorBit` BIT)  BEGIN
if ((exists(select * from nsnmember where username = nsnmember.username AND user_password = NSNMember.user_password AND NSNMember.isDeleted = false)))then
set errorBit =0;
else
set errorBit =1;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `makeAnOffer` (IN `supplier_id` INT, IN `requester_id` INT, IN `price` INT, IN `request_num` INT, OUT `error_bit` BIT)  BEGIN
SET @t = now();
IF(EXISTS(SELECT * FROM Supply WHERE Supply.member_id = requester_id AND Supply.request_num = request_num)) THEN
SET error_bit = 0;
CALL areNeighbours(supplier_id, requester_id, @c);
IF(@c = 1 AND supplier_id <> requester_id) THEN
INSERT INTO Offer(supplier_id, requester_id, price, request_num, offer_status, offered_time) VALUES (supplier_id, requester_id, price, request_num, 'pending',@t);
SET error_bit = 0;
ELSE
SET error_bit =1;
END IF;
ELSE
SET error_bit = 1;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `memberINgroup` (IN `memberID` INT, IN `groupID` INT, OUT `checkBit` BIT)  BEGIN
	IF(not groupID is null) then
		 IF (exists (select * from joins as g,nsnmember as m,nsngroup as nsng where g.group_id=groupID and m.isDeleted = 0 and m.id=memberID and g.join_status="accepted" and g.isDeleted=0 and nsng.isDeleted = 0))then
			SET checkBit =1;
		ELSE
			SET checkBit =0;
		END IF;

	ELSE
		SET checkBit =0;

	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `numberOfFriends` (IN `member_id` INT, OUT `count` INT)  BEGIN
declare count int;
set count = (select count(*) 
from adds, nsnmember as mem
where (adds.adder_id = member_id AND adds.add_status = 'accepted' AND mem.id = adds.added_id AND mem.isDeleted=0) OR (adds.added_id = member_id AND adds.add_status = 'accepted'));
select count;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `organizeEvent` (IN `member_id` INT, IN `eventName` VARCHAR(30), IN `eventDescription` TEXT, IN `is_public` BOOL)  BEGIN
-- if(exists(select* from NSNMember where NSNMember.id = member_id ))then 
-- added a condition
set @t = now();
INSERT INTO NSN_event(event_name, event_description, is_public, organizer_id, creation_time)
VALUES( eventName, eventDescription, is_public,member_id, @t);

select event_id into @tempID from nsn_event where nsn_event.creation_time=@t; -- added check on member_id
if (is_public = 1) then
INSERT INTO public_event(event_id)
VALUES(@tempID);
else
INSERT INTO private_event(event_id)
VALUES(@tempID);
CALL inviteMember(member_id, @tempID, member_id, @c);
UPDATE invitedtoprivateevent
SET invitation_status = 'accepted'
WHERE invitedtoprivateevent.event_id = @tempID AND invitedtoprivateevent.invited_id =member_id;
end if;
-- end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `postNews` (IN `poster_id` INT, IN `_content` TEXT)  NO SQL
BEGIN
INSERT INTO Post(uploader_id, content, post_time) 
VALUES (poster_id, _content, now());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PostNewsInGroup` (IN `poster_id` INT, IN `content` TEXT, IN `group_id` INT, OUT `errorBit` BIT)  BEGIN
	IF(group_id IS NULL)THEN
		INSERT INTO Post(uploader_id, content, post_time) VALUES (poster_id, content, now());
        set errorBit=1;
	ELSE
		CALL memberIngroup(poster_id, group_id,@c);
		IF(@c=1)THEN
			INSERT INTO post(uploader_id, content,group_id,post_time) VALUES (poster_id, content, group_id,now());
			set errorBit=1;
		ELSE set errorBit=0;
		END IF;
	END IF;
    SELECT errorBit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rate` (IN `subject_id` INT, IN `object_id` INT, IN `r_value` INT)  BEGIN
CALL areNeighbours(subject_id, object_id, @c); -- howa f arefriends by-check enohom neighbours ?
IF(@c = 1 ) THEN
IF( NOT EXISTS (SELECT * FROM Rates WHERE rater_id = subject_id AND rated_id = object_id)) THEN
INSERT INTO rates (rater_id, rated_id, rate_value) VALUES (subject_id, object_id, r_value);
ELSE
	UPDATE Rates
    SET rate_value = r_value WHERE rater_id = subject_id AND rated_id = object_id;
    END IF;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `removeGroupMember` (IN `admin_id` INT, IN `member_id` INT, IN `group_id` INT, OUT `checkBIT` BIT)  BEGIN

    IF(EXISTS(SELECT * FROM joins AS j WHERE j.member_id = admin_id AND j.group_id = group_id AND j.is_admin = 1 AND j.isDeleted = 0 AND j.join_status = 'accepted'))
		THEN
			IF(EXISTS(SELECT * FROM joins AS j WHERE j.member_id = member_id AND (j.join_status = 'accepted' or j.join_status = 'pending')  AND j.isDeleted = 0 AND j.group_id = group_id))
				THEN
					SET checkBIT = 0;
					UPDATE joins as j
                    SET j.join_status = 'rejected',j.is_admin = 0,j.isDeleted = 1
                    WHERE j.member_id = member_id AND (j.join_status = 'accepted' or j.join_status = 'pending')  AND j.isDeleted = 0 AND j.group_id = group_id;	-- sarah checked
				ELSE
					SET checkBIT = 1;
				END IF;
		END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `removeMemberFromEvent` (IN `member_id` INT, IN `event_id` INT, IN `creator_id` INT, OUT `errorBit` BIT)  BEGIN
if( exists(select * from private_event where private_event.event_id = event_id) -- lazm yb2a private event
AND ((select organizer_id  from NSN_event as mem where mem.event_id = event_id) = creator_id) -- lazm el by7awl y8yr yb2a howa el creator
AND (exists(select * from InvitedToPrivateEvent as e where e.event_id = event_id AND e.invited_id = member_id))) then -- lazm yb2a f el event
Update InvitedToPrivateEvent
Set isDeleted = 1
where InvitedToPrivateEvent.event_id = event_id AND InvitedToPrivateEvent.invited_id = member_id ;
set errorBit = 0;
else
set errorBit = 1;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `report` (IN `subject_id` INT, IN `object_id` INT, IN `content` TEXT, OUT `errorBit` BIT)  BEGIN
	call areNeighbours(subject_id, object_id,@c);

	IF(@c=1 and not exists (select * from reports where reporter_id=subject_id and reported_id=object_id))THEN
		SET @t = now();
        INSERT INTO reports(reporter_id, reported_id, report_content,report_time) VALUES (subject_id, object_id, content,@t); 
        set errorBit=0;
	ELSE

			set errorBit=1; -- already reported once or not neighbours
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `requestItem` (IN `member_id` INT, IN `supply_name` VARCHAR(30), IN `supply_description` TEXT)  BEGIN
SET @t = now();
INSERT INTO Supply (member_id, supply_name, supply_description, requested_time) VALUES (member_id, supply_name, supply_description, @t);
INSERT INTO Item
SELECT request_num FROM Supply
WHERE Supply.requested_time = @t AND Supply.member_id = member_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `requestService` (IN `member_id` INT, IN `supply_name` VARCHAR(30), IN `supply_description` TEXT, IN `start_time` DATETIME, IN `end_time` DATETIME)  BEGIN
SET @t = now();
INSERT INTO Supply (member_id, supply_name, supply_description, requested_time) VALUES (member_id, supply_name, supply_description, @t);
SELECT request_num INTO @req_num FROM Supply
WHERE Supply.requested_time = @t AND Supply.member_id = member_id;
INSERT INTO Service(request_num, start_time, end_time) VALUES(@req_num, start_time, end_time);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `respondToEventInvitation` (IN `member_id` INT, IN `event_id` INT, IN `astatus` VARCHAR(30))  BEGIN

Update InvitedToPrivateEvent
set invitation_status = astatus
where  invited_id = member_id and event_id = event_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `respondToFriendRequest` (IN `sender_id` INT, IN `receiver_id` INT, IN `request_status` VARCHAR(30))  BEGIN
IF(request_status = 'rejected')THEN
DELETE FROM adds
WHERE adds.adder_id = sender_id AND adds.added_id = receiver_id;
ELSE
UPDATE adds
SET add_status = request_status
Where adds.adder_id = sender_id AND adds.added_id = receiver_id;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `respondToGroupInvitation` (IN `member_id` INT, IN `group_id` INT, IN `response` VARCHAR(30), OUT `checkBIT` BIT)  BEGIN
	IF (EXISTS(SELECT * FROM NSNMember AS MEM WHERE MEM.id= member_id AND MEM.isDeleted = 0 ))
		THEN
			IF(EXISTS(SELECT * FROM joins AS j WHERE j.member_id = member_id AND j.join_status = 'pending' AND j.isDeleted = 0))
				THEN
					SET checkBIT = 0;
					UPDATE joins
					SET joins.join_status = response
					WHERE joins.member_id = member_id AND joins.join_status = 'pending' AND joins.isDeleted = 0 and joins.group_id=group_id; -- sarah checked
				ELSE
					SET checkBIT = 1;
			END IF;
		END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `respondToOffer` (IN `responder_id` INT, IN `supplier_id` INT, IN `request_num` INT, IN `offer_response` VARCHAR(30), OUT `error_bit` BIT)  BEGIN
CALL areNeighbours(responder_id, supplier_id, @c);
IF(EXISTS (SELECT * FROM Supply WHERE Supply.request_num = request_num AND Supply.member_id = responder_id) AND @c) THEN
	IF(offer_response = 'accepted') THEN
	UPDATE Supply
    SET Supply.request_status = 'resolved'
    WHERE (Supply.request_num = request_num AND Supply.member_id = responder_id);
    ELSE
    UPDATE Supply
    SET Supply.request_status = 'pending'
    WHERE (Supply.request_num = request_num AND Supply.member_id = responder_id);
    END IF;
	UPDATE Offer
	SET Offer.offer_status = offer_response
	WHERE Offer.request_num = request_num;
	SET error_bit = 0;
	ELSE SET error_bit = 1;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `searchSuppliesByName` (IN `member_id` INT, IN `search_term` TEXT)  BEGIN
SELECT supply_name, supply_description, requested_time, request_status, username, first_name, last_name FROM Supply AS s1, nsnmember as mem
WHERE s1.isDeleted = 0 AND (s1.supply_name = search_term OR search_term = '') AND EXISTS(SELECT * FROM NSNMember AS m1, NSNMember AS m2, Supply AS s2 WHERE m1.id = member_id AND m2.id = s1.member_id AND m1.street_name = m2.street_name) AND mem.id = s1.member_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sendFriendRequest` (IN `sender_id` INT, IN `receiver_id` INT)  BEGIN
CALL areNeighbours(sender_id, receiver_id, @checkbit);
IF(@checkbit
AND EXISTS(SELECT * FROM NSNMember AS M WHERE M.id = receiver_id AND M.isDeleted = false)) THEN
INSERT INTO adds(adder_id, added_id, request_time)
VALUES(sender_id, receiver_id, now());
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sendMessage` (IN `subject_id` INT, IN `object_id` INT, IN `message_content` TEXT, OUT `error_bit` BIT)  BEGIN
CALL areNeighbours(subject_id, object_id, @check1);
IF(@check1 AND not exists (select* from blocks where (blocks.blocker_id = subject_id AND blocks.blocked_id = object_id ) OR (blocks.blocker_id = object_id AND blocks.blocked_id = subject_id ))) THEN
INSERT INTO message(sender_id, receiver_id, message_content , message_time) VALUES(subject_id, object_id, message_content, now());
SET error_bit = 1;
ELSE
SET error_bit = 0;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `signUp` (IN `username` VARCHAR(30), IN `user_password` VARCHAR(30), IN `first_name` VARCHAR(30), IN `last_name` VARCHAR(30), IN `house_number` INT, IN `postal_code` INT, IN `street_name` VARCHAR(30), OUT `errorBit` BIT)  BEGIN
if (exists (select * from nsnmember where (username = nsnmember.username)))
then
set errorBit =1;
else
set errorBit =0;
INSERT INTO nsnmember(username, first_name , last_name, house_number, postal_code, street_name, user_password)
VALUES(username, first_name , last_name, house_number, postal_code, street_name, user_password);
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateCommentOnNews` (IN `member_ID` INT, IN `_time` DATETIME, IN `post_ID` INT, IN `content` TEXT, OUT `errorBit` BIT)  BEGIN
	
	--  1- check if the owner of the post is a neighbour to the member trying to comment
    -- 2- member can comment either if the group is null(post doesnot belong to a group ) or if the the commenter and the post belong to the same group
    IF(
    exists (select * from nsnmember as mem1 ,nsnmember as mem2,post where (post.isDeleted = 0 and mem1.isDeleted = 0 and mem2.isDeleted = 0 and post.post_id=post_ID and mem1.id=post.uploader_id and mem2.id=member_ID and mem1.street_name=mem2.street_name)
			and(
				(post.group_id is null) 
                or
                ( exists (select * from joins where (joins.member_id=member_ID and joins.group_id=post.group_id) ))
                )
			)
		)THEN 
        IF ( exists(select * from nsncomment where nsncomment.isDeleted =0 and nsncomment.post_id=post_id and nsncomment.commenter_id=member_ID and nsncomment.comment_time=_time)) then
			update nsncomment set comment_contenet=content, comment_time = now() where  nsncomment.post_id=post_id and nsncomment.commenter_id=member_ID and nsncomment.comment_time=_time;
			set errorBit=0;
        ELSE
        		set errorBit=1;
        END IF;
	ELSE
		set errorBit=1;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateDescription` (IN `creator_id` INT, IN `event_id` INT, IN `newEventDescription` TEXT, OUT `error_bit` BIT)  BEGIN
if ((select organizer_id  from NSN_event as mem where mem.event_id = event_id) = creator_id) then
Update NSN_event
Set event_description = newEventDescription
where NSN_event.event_id = event_id;
set error_bit = 0;
else
set error_bit = 1;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateName` (IN `member_id` INT, IN `newFirstName` VARCHAR(30), IN `newLastName` VARCHAR(30))  BEGIN
if(exists(select * from nsnmember where (member_id = nsnmember.id) AND NSNMember.isDeleted = false))then
UPDATE NSNMember
set first_name = newFirstName,
last_name = newLastName
where NSNMember.id = member_id;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updatePassword` (IN `member_id` INT, IN `oldPassword` VARCHAR(30), IN `newPassword` VARCHAR(30), OUT `errorBit` BIT)  BEGIN
if ((select user_password from NSNMember where NSNMember.id = member_id AND NSNMember.isDeleted = false) = oldPassword) then
UPDATE NSNMember
set user_password = newPassword
where NSNMember.id = member_id;
set errorBit = 0;
else 
set errorBit = 1;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updatePostNews` (IN `poster_id` INT, IN `post_id` INT, IN `_content` TEXT, OUT `errorBit` BIT)  BEGIN
	IF( EXISTS(SELECT * FROM post WHERE (post.isDeleted=0 and post.post_id = post_id and post.uploader_id = poster_id) )) THEN
		UPDATE post set content = _content where (post.post_id = post_id and post.uploader_id = poster_id) ;
        set errorBit=0;
	ELSE
		 set errorBit=1;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateSupplyInfo` (IN `new_name` VARCHAR(30), IN `new_description` TEXT, IN `request_num` INT, IN `editor_id` INT)  BEGIN
UPDATE Supply
SET supply_name = new_name, supply_description = new_description
WHERE Supply.member_id = editor_id AND Supply.request_num = request_num;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewChats` (IN `member_id` INT)  BEGIN
	call viewChatshelper(member_id);
	drop table temp;
	drop table temp2;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewChatshelper` (IN `member_id` INT)  BEGIN
	CREATE table TEMP(receiver_id INT,sender_id INT,message_content TEXT,message_time DATETIME);
	CREATE table TEMP2(receiver_id INT,sender_id INT,message_content TEXT,message_time DATETIME);

	INSERT INTO TEMP 
	SELECT a.receiver_id, a.sender_id, a.message_content, a.message_time
	FROM message a
		INNER JOIN (
		SELECT receiver_id, sender_id, MAX(message_time) message_time
		FROM message
		GROUP BY receiver_id, sender_id
		) b ON a.receiver_id = b.receiver_id AND a.message_time = b.message_time AND a.sender_id = b.sender_id
	WHERE a.sender_id = member_id OR a.receiver_id = member_id;


	INSERT INTO TEMP2
	SELECT t1.receiver_id, t1.sender_id, t1.message_content, t1.message_time
	FROM TEMP t1
	WHERE Not EXISTS (select * from TEMP t2 where (t1.sender_id=t2.receiver_id and t2.sender_id=t1.receiver_id))
		or
		EXISTS (select * from TEMP t2 where (t1.sender_id=t2.receiver_id and t2.sender_id=t1.receiver_id and t1.message_time>t2.message_time));


	SELECT n.first_name as sender_first_name, n.last_name as sender_last_name, n.id as sender_id ,n2.first_name as receiver_first_name, n2.last_name as receiver_last_name, n2.id as receiver_id, c.message_content, c.message_time
	FROM NSNMember AS n,NSNMember AS n2, TEMP2 as c
	WHERE ((n.id = sender_id and n2.id = receiver_id));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewCloseNeighbours` (IN `member_id` INT)  BEGIN
select mem.username, mem.first_name, mem.last_name from NSNMember as mymem, NSNMember as mem
where NOT EXISTS(SELECT * FROM Blocks WHERE (Blocks.blocker_id = mymem.id AND Blocks.blocked_id = mem.id) OR (Blocks.blocker_id = mem.id AND Blocks.blocked_id = mymem.id)) -- no one blocked the other
AND mem.isDeleted = false AND mymem.id = member_id AND mem.house_number = mymem.house_number AND (mem.postal_code = mymem.postal_code) AND (mem.street_name = mymem.street_name) AND (mem.id <> member_id) AND mem.isDeleted = 0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewComments` (IN `post_id` INT)  NO SQL
BEGIN
SELECT nsncomment.comment_contenet, nsnmember.first_name, nsnmember.last_name, nsncomment.comment_time FROM post,nsncomment, nsnmember WHERE post.post_id = nsncomment.post_id AND post.post_id=post_id AND nsnmember.id = nsncomment.commenter_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewConversation` (IN `subject_id` INT, IN `object_id` INT)  BEGIN
CALL areNeighbours(subject_id, object_id, @check);
IF(@check) THEN
SELECT * FROM message
WHERE (message.sender_id = subject_id AND message.receiver_id = object_id) OR (message.sender_id = object_id AND message.receiver_id = subject_id);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewCreatorInvitedMembers` (IN `organizer_id` INT, IN `event_id` INT)  BEGIN
select DISTINCT mem.id,mem.username, mem.first_name, mem.last_name
from InvitedToPrivateEvent as i, NSNMember as mem, NSN_event as e
where i.invitation_status = 'pending' AND i.event_id = e.event_id AND i.event_id = event_id AND e.organizer_id = organizer_id AND i.invited_id = mem.id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewEvents` (IN `member_id` INT)  NO SQL
BEGIN
	SELECT e.organizer_id,mem.first_name,mem.last_name,e.event_id,e.event_name,e.event_description,e.creation_time
    FROM nsn_event as e, nsnmember as mem , nsnmember as mem2
    WHERE e.organizer_id = mem.id AND mem2.id = member_id AND mem.street_name = mem2.street_name AND mem.postal_code = mem2.postal_code AND e.is_public = 1 AND e.isDeleted=0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewGoingMembers` (IN `member_id` INT, IN `event_id` INT)  BEGIN
if (exists (select * from InvitedToPrivateEvent as i where i.invited_id = member_id AND (i.invitation_status = 'accepted' OR i.invitation_status = 'pending') AND i.isDeleted=0))
then
select  mem.id, mem.username, mem.first_name, mem.last_name 
from InvitedToPrivateEvent as ev, NSNMember as mem
where  mem.id = ev.invited_id AND ev.invitation_status ='accepted' AND ev.event_id=event_id;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewGroupInvitationRequests` (IN `member_id` INT)  BEGIN

SELECT joins.group_id, nsngroup.group_name FROM joins,nsngroup WHERE joins.member_id = member_id AND joins.isDeleted = 0 AND joins.join_status = 'pending' AND nsngroup.group_id = joins.group_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewGroupJoinedMembers` (IN `member_id` INT, IN `group_id` INT, OUT `checkBIT` BIT)  BEGIN
	IF (EXISTS(SELECT * FROM NSNMember AS MEM WHERE MEM.id= member_id AND MEM.isDeleted = 0 )) -- check 2no 2l member fl database -->malha4 lazma
		THEN
			IF (EXISTS(SELECT * FROM joins AS j WHERE j.member_id = member_id AND j.group_id = group_id AND j.isDeleted = 0 AND j.join_status = 'accepted')) -- sarah checked
            -- bit2kd 2no member fl group wel status accepted we 2no 2l group makan4 deleted
				THEN
					SELECT MEM.username,MEM.id, MEM.first_name,MEM.last_name FROM NSNMember AS MEM, joins AS j WHERE MEM.id= j.member_id AND j.group_id = group_id AND j.isDeleted = 0 AND j.join_status = 'accepted';
					SET checkBIT = 0;
				ELSE
					SET checkBIT = 1;
				END IF;
		END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewGroupPosts` (IN `viewer_id` INT, IN `group_id` INT, OUT `errorBit` BIT)  BEGIN
call memberINgroup(viewer_id, group_id,@c);
	IF(@c=1)THEN
		select * from  Post,nsnmember as mem where mem.id = post.uploader_id AND post.group_id=group_id and post.isDeleted=0;
        set errorBit=0;
	ELSE
		set errorBit=1;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewInvited` (IN `admin_id` INT, IN `group_id` INT, OUT `checkBIT` BIT)  BEGIN

    IF(EXISTS(SELECT * FROM joins AS j WHERE j.member_id = admin_id AND j.group_id = group_id AND j.is_admin = 1 AND j.isDeleted = 0 AND j.join_status = 'accepted'))
		THEN
			SET checkBIT = 0;
			SELECT mem.first_name, mem.last_name FROM joins AS j, nsnmember as mem WHERE mem.id=j.member_id and j.group_id = group_id AND j.join_status = 'pending';  -- sarah checked
		ELSE
			SET checkBIT = 1;
        END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewMemberNews` (IN `subject_ID` INT, IN `object_ID` INT, OUT `errorBit` BIT)  BEGIN
	CALL areNeighbours(subject_ID, object_ID,@c);
	IF(@c=1 or subject_ID = object_ID)THEN 
		select * from post where post.uploader_id=object_ID and post.isDeleted = 0 and (post.group_id is null or (  exists (select * from joins where ((joins.member_id=subject_ID and joins.group_id=post.group_id)) ) ) or object_ID=subject_ID); 
        set errorBit=0;
	ELSE
		set errorBit=1;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewMemberRequestedSupplies` (IN `subject_id` INT, IN `object_id` INT, OUT `error_bit` BIT)  BEGIN
CALL areNeighbours(subject_id, object_id, @c);
IF(@c = 1) THEN
SELECT supply_name, supply_description, requested_time, start_time, end_time, username, first_name, last_name FROM NSNMember, Supply LEFT JOIN Service
ON Supply.request_num = Service.request_num
WHERE Supply.member_id = object_id AND NSNMember.id = Supply.member_id AND Supply.isDeleted=0;
SET error_bit = 0;
ELSE
SET error_bit = 1;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewMyGoingEvents` (IN `member_id` INT)  BEGIN
select e.event_id,e.event_description,e.organizer_id,e.creation_time ,e.event_name, mem.username, mem.first_name, mem.last_name
from InvitedToPrivateEvent as i, nsn_event as e, NSNMember as mem
where (i.invited_id = member_id AND i.event_id = e.event_id AND mem.id = e.organizer_id and e.isDeleted=0) AND i.invitation_status = 'accepted';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewMyGroups` (IN `member_id` INT)  BEGIN
-- sarah checked
	SELECT NSNG.group_id,NSNG.group_name,NSNG.isDeleted,NSNG.creator_id,NSNG.creation_date FROM NSNgroup AS NSNG,joins WHERE NSNG.group_id = joins.group_id AND joins.member_id = member_id AND joins.join_status = 'accepted' AND joins.isDeleted = 0 AND NSNG.isDeleted=0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewMyInvitedEvents` (IN `member_id` INT)  BEGIN
select e.event_id , e.event_name, mem2.first_name,mem2.last_name,e.event_description
from InvitedToPrivateEvent as i, NSNMember as mem, nsnmember as mem2, NSN_event as e
where mem.id = member_id AND mem2.id=e.organizer_id  AND mem.id = i.invited_id AND i.invitation_status = 'pending' AND i.event_id = e.event_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewMyMutualGroups` (IN `member1_id` INT, IN `member2_id` INT, OUT `checkBIT` BIT)  BEGIN
call areNeighbours(member1_id, member2_id, @c);
	
        IF (@c=1)
		THEN
			SET checkBIT = 0;
			SELECT NSNG.group_id,NSNG.group_name, NSNG.creation_date FROM NSNgroup AS NSNG, joins AS j1,joins AS j2 WHERE NSNG.group_id = j1.group_id AND NSNG.group_id = j2.group_id AND j1.member_id = member1_id AND j2.member_id = member2_id AND j1.isDeleted=0 and j2.isDeleted=0 and NSNG.isDeleted=0 AND j1.join_status="accepted" AND j2.join_status="accepted";
        ELSE
			SET checkBIT = 1;
        END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewMyOrganizedEvents` (IN `member_id` INT)  BEGIN
select e.event_name
from NSNMember as mem, NSN_event as e
where mem.id = member_id AND mem.id = e.organizer_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewMyRequests` (IN `member_id` INT)  BEGIN
SELECT Supply.request_num, supply_name, supply_description, requested_time, start_time, end_time, request_status FROM Supply LEFT JOIN Service
ON Supply.request_num = Service.request_num
WHERE Supply.member_id = member_id AND supply.isDeleted = 0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewNeighbourPosts` (IN `subject_ID` INT)  NO SQL
BEGIN
	select mem.first_name, mem.last_name,post.post_id, post.content, post.uploader_id, post.group_id, post.post_time from post , nsnmember as mem, nsnmember as mem2 where mem2.id=subject_ID AND mem2.street_name = mem.street_name AND mem.postal_code = mem2.postal_code AND post.uploader_id=mem.id and post.isDeleted = 0 and (post.group_id is null or (  exists (select * from joins where ((joins.member_id=subject_ID and joins.group_id=post.group_id)) ) ) or mem.id=subject_ID); 
	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewOffersOnARequest` (IN `subject_id` INT, IN `object_id` INT, IN `request_num` INT, OUT `error_bit` BIT)  BEGIN
CALL areNeighbours(subject_id, object_id, @c);
IF(@c = 1) THEN
SELECT supply_name, supply_description, price, offer_status, supplier_id, S.request_num, N.first_name, N.last_name FROM Offer AS O, Supply AS S, NSNMember AS N
WHERE O.request_num = S.request_num AND S.request_num = request_num AND S.member_id = object_id AND S.isdeleted = 0 AND N.id = O.supplier_id;
SET error_bit = 0;
ELSE
SET error_bit = 1;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewOffersOnMyRequests` (IN `_member_id` INT)  BEGIN
SELECT supply_name, supply_description, price, offer_status, supplier_id , first_name, last_name, username FROM Offer, Supply , nsnmember
WHERE Offer.request_num = Supply.request_num AND Supply.member_id = offer.requester_id 
AND Offer.supplier_id = nsnmember.id AND supply.isDeleted = 0 AND offer.isDeleted = 0 AND Supply.member_id = _member_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewReport` (IN `member_id` INT)  BEGIN
	select* from reports where reported_id=member_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewRequestsReceived` (IN `member_id` INT)  BEGIN
select  req.adder_id, mem.username, mem.first_name, mem.last_name, req.add_status 
from Adds as req, NSNmember as mem
where req.added_id = member_id AND req.adder_id = mem.id AND mem.isDeleted = false;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewRequestsSent` (IN `member_id` INT)  BEGIN
select  req.added_id, mem.username, mem.first_name, mem.last_name, req.add_status 
from Adds as req, NSNmember as mem
where req.adder_id = member_id AND req.added_id = mem.id AND req.isDeleted = false;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewServices` (IN `member_id` INT)  NO SQL
BEGIN
	select se.start_time,se.end_time,s.request_num,s.isDeleted,s.supply_name,s.supply_description,s.requested_time,s.member_id,s.request_status, mem2.first_name, mem2.last_name, mem2.username, mem2.house_number
    from supply as s, nsnmember as mem1, nsnmember as mem2, service as se
    where s.member_id = mem2.id AND mem1.id = member_id AND mem1.street_name=mem2.street_name AND mem1.isDeleted = 0 and mem2.isDeleted = 0 AND se.request_num = s.request_num;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewStreetNeighbours` (IN `member_id` INT)  BEGIN
select mem.id, mem.username, mem.first_name, mem.last_name from NSNMember as mymem, NSNMember as mem
where NOT EXISTS(SELECT * FROM Blocks WHERE (Blocks.blocker_id = mymem.id AND Blocks.blocked_id = mem.id) OR (Blocks.blocker_id = mem.id AND Blocks.blocked_id = mymem.id)) -- no one blocked the other
AND mem.isDeleted = false AND mymem.id = member_id  AND (mem.postal_code = mymem.postal_code) AND (mem.street_name = mymem.street_name) AND (mem.id <> member_id) AND mem.isDeleted = 0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `viewSupplies` (IN `member_id` INT)  NO SQL
BEGIN
	select s.request_num,s.isDeleted,s.supply_name,s.supply_description,s.requested_time,s.member_id,s.request_status, mem2.first_name, mem2.last_name, mem2.username, mem2.house_number
    from supply as s, nsnmember as mem1, nsnmember as mem2
    where s.member_id = mem2.id AND mem1.id = member_id AND mem1.street_name=mem2.street_name AND mem1.isDeleted = 0 and mem2.isDeleted = 0 ;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `adds`
--

CREATE TABLE `adds` (
  `adder_id` int(11) NOT NULL,
  `added_id` int(11) NOT NULL,
  `isDeleted` tinyint(1) DEFAULT 0,
  `request_time` datetime NOT NULL,
  `add_status` varchar(30) DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `adds`
--

INSERT INTO `adds` (`adder_id`, `added_id`, `isDeleted`, `request_time`, `add_status`) VALUES
(1, 4, 0, '2019-12-09 12:43:50', 'pending'),
(1, 11, 0, '2019-12-12 13:51:37', 'pending'),
(17, 30, 0, '2019-12-12 13:38:57', 'accepted');

-- --------------------------------------------------------

--
-- Table structure for table `blocks`
--

CREATE TABLE `blocks` (
  `blocker_id` int(11) NOT NULL,
  `blocked_id` int(11) NOT NULL,
  `blocked_time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `house`
--

CREATE TABLE `house` (
  `house_number` int(11) NOT NULL,
  `postal_code` int(11) NOT NULL,
  `street_name` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `house`
--

INSERT INTO `house` (`house_number`, `postal_code`, `street_name`) VALUES
(0, 10115, 'Bernauer Straße'),
(0, 10115, 'Friedrichstraße'),
(0, 10115, 'Jüdenstraße'),
(0, 10117, 'Bernauer Straße'),
(0, 10117, 'Friedrichstraße'),
(0, 10119, 'Friedrichstraße'),
(1, 10115, 'Bernauer Straße'),
(1, 10115, 'Jüdenstraße'),
(1, 10117, 'Friedrichstraße'),
(1, 10117, 'Jüdenstraße'),
(1, 10119, 'Friedrichstraße'),
(1, 10119, 'Jüdenstraße'),
(2, 10115, 'Bernauer Straße'),
(2, 10115, 'Friedrichstraße'),
(2, 10115, 'Jüdenstraße'),
(2, 10117, 'Bernauer Straße'),
(2, 10117, 'Friedrichstraße'),
(2, 10117, 'Jüdenstraße');

-- --------------------------------------------------------

--
-- Table structure for table `invitedtoprivateevent`
--

CREATE TABLE `invitedtoprivateevent` (
  `invited_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `isDeleted` tinyint(1) DEFAULT 0,
  `invited_time` datetime DEFAULT NULL,
  `invitation_status` varchar(30) DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `invitedtoprivateevent`
--

INSERT INTO `invitedtoprivateevent` (`invited_id`, `event_id`, `isDeleted`, `invited_time`, `invitation_status`) VALUES
(1, 20, 0, '2019-12-10 12:58:04', 'accepted'),
(1, 23, 0, '2019-12-10 13:45:47', 'accepted'),
(1, 25, 0, '2019-12-10 16:46:10', 'accepted'),
(1, 26, 0, '2019-12-10 16:53:09', 'accepted'),
(1, 28, 0, '2019-12-12 10:46:16', 'accepted'),
(1, 29, 0, '2019-12-12 13:45:52', 'accepted'),
(1, 30, 0, '2019-12-12 15:25:24', 'accepted'),
(1, 32, 0, '2019-12-12 15:26:00', 'accepted'),
(11, 26, 0, '2019-12-12 10:27:01', 'accepted'),
(11, 28, 0, '2019-12-12 10:45:19', 'accepted'),
(11, 29, 0, '2019-12-12 13:46:38', 'pending'),
(17, 23, 0, '2019-12-10 15:44:45', 'accepted'),
(17, 26, 0, '2019-12-10 16:56:01', 'accepted'),
(17, 29, 0, '2019-12-12 13:46:45', 'pending'),
(17, 30, 0, '2019-12-12 15:26:14', 'pending'),
(19, 30, 0, '2019-12-12 15:26:15', 'pending'),
(30, 20, 0, '2019-12-10 16:57:13', 'accepted'),
(30, 23, 0, '2019-12-10 15:45:14', 'accepted'),
(30, 26, 0, '2019-12-10 16:53:27', 'accepted');

-- --------------------------------------------------------

--
-- Table structure for table `item`
--

CREATE TABLE `item` (
  `request_num` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `item`
--

INSERT INTO `item` (`request_num`) VALUES
(1),
(2),
(3),
(4),
(5),
(6);

-- --------------------------------------------------------

--
-- Table structure for table `joins`
--

CREATE TABLE `joins` (
  `group_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `isDeleted` tinyint(1) DEFAULT 0,
  `join_status` varchar(30) DEFAULT 'pending',
  `is_admin` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `joins`
--

INSERT INTO `joins` (`group_id`, `member_id`, `isDeleted`, `join_status`, `is_admin`) VALUES
(1, 1, 1, 'accepted', 0),
(1, 11, 1, 'accepted', 0),
(2, 1, 1, 'accepted', 0),
(2, 11, 0, 'accepted', 0),
(3, 11, 0, 'accepted', 1),
(4, 11, 1, 'accepted', 0),
(5, 11, 1, 'accepted', 0),
(6, 11, 1, 'accepted', 0),
(7, 11, 1, 'accepted', 0),
(8, 1, 0, 'accepted', 1),
(8, 11, 1, 'accepted', 0),
(8, 30, 0, 'accepted', 0),
(9, 1, 0, 'accepted', 1),
(9, 11, 0, 'pending', 0),
(10, 1, 0, 'accepted', 1),
(10, 11, 0, 'rejected', 0),
(10, 17, 0, 'pending', 0),
(10, 30, 0, 'pending', 0),
(11, 1, 0, 'accepted', 1),
(12, 1, 0, 'rejected', 0),
(12, 11, 0, 'accepted', 1),
(13, 1, 0, 'accepted', 0),
(13, 11, 0, 'pending', 0),
(13, 30, 0, 'accepted', 1);

-- --------------------------------------------------------

--
-- Table structure for table `likes`
--

CREATE TABLE `likes` (
  `post_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

CREATE TABLE `message` (
  `message_time` datetime NOT NULL,
  `message_content` text DEFAULT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `message`
--

INSERT INTO `message` (`message_time`, `message_content`, `sender_id`, `receiver_id`) VALUES
('2019-12-05 17:49:54', 'Hello', 1, 4),
('2019-12-05 21:41:22', 'Hello to you too!', 4, 1),
('2019-12-05 21:41:27', 'Hello to you too!', 1, 4),
('2019-12-05 21:41:28', 'Hello to you too!', 1, 4),
('2019-12-05 21:42:45', 'Hello to you too!', 11, 1),
('2019-12-05 21:55:18', 'Whats up?', 1, 11),
('2019-12-06 12:33:39', 'Whats up?', 1, 11),
('2019-12-06 12:33:58', 'Whats up?', 1, 11),
('2019-12-06 12:34:15', 'Whats up?', 1, 11),
('2019-12-06 12:34:40', 'Whats up?', 1, 11),
('2019-12-06 12:34:45', 'Whats up?', 1, 11),
('2019-12-06 12:35:11', 'Whats up?', 1, 11),
('2019-12-06 12:35:16', 'Whats up?', 1, 11),
('2019-12-06 12:35:30', 'Whats up?', 1, 11),
('2019-12-06 12:35:33', 'Whats up?', 1, 11),
('2019-12-06 12:52:24', 'Whats up?', 1, 11),
('2019-12-06 12:53:11', 'Whats up?', 1, 11),
('2019-12-06 12:53:14', 'Whats up?', 1, 11),
('2019-12-06 13:02:51', 'Whats up?', 1, 11),
('2019-12-06 13:03:09', 'Whats up?', 1, 11),
('2019-12-06 13:03:26', 'Whats up?', 1, 11),
('2019-12-06 13:04:03', 'Whats up?', 1, 11),
('2019-12-06 13:04:15', 'Whats up?', 1, 11),
('2019-12-06 13:04:26', 'Whats up?', 1, 11),
('2019-12-06 13:04:46', 'Whats up?', 1, 11),
('2019-12-06 13:05:04', 'Whats up?', 1, 11),
('2019-12-06 13:05:16', 'Whats up?', 1, 11),
('2019-12-06 13:05:32', 'Whats up?', 1, 11),
('2019-12-06 13:05:35', 'Whats up?', 1, 11),
('2019-12-06 13:05:39', 'Whats up?', 1, 11),
('2019-12-06 13:05:58', 'Whats up?', 1, 11),
('2019-12-06 13:06:06', 'Whats up?', 1, 11),
('2019-12-06 13:06:12', 'Whats up?', 1, 11),
('2019-12-06 13:08:48', 'Whats up?', 1, 11),
('2019-12-06 13:09:22', 'Whats up?', 1, 11),
('2019-12-06 13:09:44', 'Whats up?', 1, 11),
('2019-12-06 13:10:52', 'Whats up?', 1, 11),
('2019-12-06 13:13:06', 'Whats up?', 1, 11),
('2019-12-06 13:14:07', 'Whats up?', 1, 11),
('2019-12-06 13:15:05', 'Whats up?', 15, 1),
('2019-12-06 13:17:15', 'Good morning?', 19, 1),
('2019-12-06 13:17:45', 'Good morning?', 19, 1),
('2019-12-06 13:18:04', 'Good morning?', 19, 1),
('2019-12-06 13:18:18', 'Good morning?', 19, 1),
('2019-12-06 13:18:55', 'Good morning?', 19, 1),
('2019-12-06 13:19:10', 'Good morning?', 19, 1),
('2019-12-06 13:19:17', 'Good morning?', 19, 1),
('2019-12-06 13:19:27', 'Good morning?', 19, 1),
('2019-12-06 19:38:58', 'Test', 1, 4),
('2019-12-06 19:39:03', 'Test', 1, 4),
('2019-12-06 19:41:15', 'Bye', 1, 4),
('2019-12-06 19:42:09', '123', 1, 4),
('2019-12-06 19:43:42', 'emad', 1, 4),
('2019-12-06 19:44:03', 'emad', 4, 1),
('2019-12-06 19:44:14', 'emad', 4, 1),
('2019-12-06 19:46:52', 'My name is Sim Shady', 4, 1),
('2019-12-06 20:04:21', 'My name is Sim Shady', 4, 1),
('2019-12-07 12:04:22', '', 4, 1),
('2019-12-07 12:04:34', '', 4, 1),
('2019-12-07 12:05:28', '', 4, 1),
('2019-12-07 12:06:45', '', 4, 1),
('2019-12-07 12:06:57', '', 4, 1),
('2019-12-07 12:07:03', '', 4, 1),
('2019-12-07 12:07:25', '', 4, 1),
('2019-12-07 12:07:33', '', 4, 1),
('2019-12-07 12:38:13', 'aa', 4, 1),
('2019-12-07 12:38:24', 'aa', 4, 1),
('2019-12-07 14:13:21', 'test', 4, 1),
('2019-12-07 14:13:38', 'hi', 4, 1),
('2019-12-07 14:24:29', 'hi2', 1, 4),
('2019-12-07 14:24:40', 'hi2', 1, 4),
('2019-12-07 14:27:00', 'sarah', 1, 4),
('2019-12-07 14:27:19', 'sarah', 1, 4),
('2019-12-07 14:28:21', 'ahmed', 1, 4),
('2019-12-07 14:28:28', 'ahmed', 1, 4),
('2019-12-07 14:30:38', 'ahmed', 1, 4),
('2019-12-07 14:30:58', 'eiad', 1, 4),
('2019-12-07 14:31:10', 'sally', 1, 4),
('2019-12-07 14:33:14', 'sally', 1, 4),
('2019-12-07 14:34:11', 'Hi', 1, 4),
('2019-12-07 14:36:46', 'test', 1, 4),
('2019-12-07 14:37:25', 'test2', 1, 4),
('2019-12-07 14:43:56', 'sarah mohammed', 1, 4),
('2019-12-07 14:44:07', 'sarah mohammed', 1, 4),
('2019-12-07 14:44:38', 'sarah a', 1, 4),
('2019-12-07 14:44:45', 'sarah a', 1, 4),
('2019-12-07 14:44:58', 'eiad', 1, 4),
('2019-12-07 14:45:12', 'sarah m', 1, 4),
('2019-12-07 16:44:29', 'hi', 1, 4),
('2019-12-07 17:24:29', 'sally again', 1, 4),
('2019-12-07 17:39:48', 'hiiiiiiiii', 1, 4),
('2019-12-07 17:43:14', 'hiiiiiiiii', 1, 4),
('2019-12-07 17:43:55', 'hiiiiiiiii', 1, 4),
('2019-12-07 17:45:52', 'hiiiiiiiii', 1, 4),
('2019-12-07 17:46:34', 'hiiiiiiiiiiiii', 1, 4),
('2019-12-07 17:54:17', 'I am Steve', 1, 15),
('2019-12-07 17:56:16', 'hiiiii', 1, 19),
('2019-12-07 17:56:24', 'hiiiii', 1, 11),
('2019-12-07 18:07:23', 'ahmed emad', 1, 4),
('2019-12-07 18:07:37', 'sarah mohamed', 1, 11),
('2019-12-07 20:28:19', 'Hello', 1, 4),
('2019-12-08 08:58:11', 'hi today', 1, 4),
('2019-12-08 09:07:22', 'hi steve from username4', 4, 1),
('2019-12-08 11:47:40', 'hello sticky', 1, 4),
('2019-12-08 11:47:52', '', 1, 4),
('2019-12-08 11:48:02', '', 1, 4),
('2019-12-08 11:48:05', '', 1, 4),
('2019-12-08 21:45:47', 'hello', 1, 11),
('2019-12-09 11:46:43', 'hi Aaron', 1, 17),
('2019-12-09 11:47:11', 'hi again', 1, 17),
('2019-12-09 12:16:49', 'hello there', 1, 11),
('2019-12-09 12:18:23', 'hi Hank', 19, 30),
('2019-12-09 13:48:17', 'hasodhasd', 1, 11),
('2019-12-10 14:34:46', 'hi baneadam', 2, 18),
('2019-12-12 11:42:00', 'roo7 ente7er', 1, 4),
('2019-12-12 12:47:24', '5las nvm', 1, 4),
('2019-12-12 12:48:54', 'i unblocked u', 1, 19),
('2019-12-12 13:55:14', '', 11, 17),
('2019-12-13 23:00:07', 'hi', 11, 1);

-- --------------------------------------------------------

--
-- Table structure for table `nsncomment`
--

CREATE TABLE `nsncomment` (
  `isDeleted` tinyint(1) DEFAULT 0,
  `comment_contenet` text DEFAULT NULL,
  `comment_time` datetime NOT NULL,
  `post_id` int(11) NOT NULL,
  `commenter_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `nsncomment`
--

INSERT INTO `nsncomment` (`isDeleted`, `comment_contenet`, `comment_time`, `post_id`, `commenter_id`) VALUES
(0, 'nice', '2019-12-12 15:27:05', 1, 1),
(0, 'hi', '2019-12-12 14:42:26', 1, 11),
(0, 'hi', '2019-12-12 14:42:37', 1, 11),
(0, 'heyyyyyy', '2019-12-12 14:53:30', 1, 11),
(0, 'bad post', '2019-12-12 15:24:30', 3, 1),
(0, 'Great post man!', '2019-12-12 15:07:37', 3, 11),
(0, 'Hello', '2019-12-12 15:04:56', 16, 11),
(0, 'good post!', '2019-12-12 15:11:32', 19, 11),
(0, 'hey', '2019-12-13 03:29:13', 21, 1);

-- --------------------------------------------------------

--
-- Table structure for table `nsngroup`
--

CREATE TABLE `nsngroup` (
  `group_id` int(11) NOT NULL,
  `group_name` varchar(30) DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT 0,
  `creator_id` int(11) DEFAULT NULL,
  `creation_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `nsngroup`
--

INSERT INTO `nsngroup` (`group_id`, `group_name`, `isDeleted`, `creator_id`, `creation_date`) VALUES
(1, 'createdBy1', 0, 1, '2019-12-09 10:44:24'),
(2, '2createdBy1', 0, 1, '2019-12-09 10:44:47'),
(3, 'testing', 1, 11, '2019-12-09 17:19:40'),
(4, 'testing', 0, 11, '2019-12-09 17:19:43'),
(5, '', 0, 11, '2019-12-09 17:32:22'),
(6, '', 0, 11, '2019-12-09 17:33:04'),
(7, 'itWorked?', 0, 11, '2019-12-09 17:34:21'),
(8, 'group1', 0, 1, '2019-12-09 21:21:43'),
(9, 'group2', 0, 1, '2019-12-09 21:22:15'),
(10, 'Group   ', 0, 1, '2019-12-12 11:21:27'),
(11, '', 0, 1, '2019-12-12 11:21:47'),
(12, 'test', 0, 11, '2019-12-12 11:32:21'),
(13, 'football', 0, 30, '2019-12-12 13:40:35');

-- --------------------------------------------------------

--
-- Table structure for table `nsnmember`
--

CREATE TABLE `nsnmember` (
  `id` int(11) NOT NULL,
  `isDeleted` tinyint(1) DEFAULT 0,
  `username` varchar(30) NOT NULL,
  `first_name` varchar(30) DEFAULT NULL,
  `last_name` varchar(30) DEFAULT NULL,
  `house_number` int(11) NOT NULL,
  `postal_code` int(11) NOT NULL,
  `street_name` varchar(30) NOT NULL,
  `user_password` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `nsnmember`
--

INSERT INTO `nsnmember` (`id`, `isDeleted`, `username`, `first_name`, `last_name`, `house_number`, `postal_code`, `street_name`, `user_password`) VALUES
(1, 0, 'userName2', 'Steve', 'Nugent', 2, 10115, 'Bernauer Straße', 'passpassword2'),
(2, 0, 'userName3', 'Tim', 'Lawicki', 0, 10115, 'Friedrichstraße', 'passpassword3'),
(3, 0, 'userName4', 'Carl', 'Lawless', 2, 10117, 'Jüdenstraße', 'passpassword4'),
(4, 0, 'userName5', 'Alex', 'Anderson', 0, 10117, 'Bernauer Straße', 'passpassword5'),
(5, 0, 'userName6', 'Aaron', 'Anderson', 1, 10117, 'Jüdenstraße', 'passpassword6'),
(6, 0, 'userName7', 'Thomas', 'Haworth', 1, 10117, 'Jüdenstraße', 'passpassword7'),
(7, 0, 'userName8', 'Steve', 'Anderson', 1, 10117, 'Jüdenstraße', 'passpassword8'),
(8, 0, 'userName9', 'Ty', 'McCormack', 1, 10119, 'Friedrichstraße', 'passpassword9'),
(9, 0, 'userName10', 'Aaron', 'Bowers', 0, 10115, 'Jüdenstraße', 'passpassword10'),
(10, 0, 'userName11', 'Hank', 'Bateman', 0, 10115, 'Jüdenstraße', 'passpassword11'),
(11, 0, 'userName12', 'Roger', 'Kassing', 2, 10115, 'Bernauer Straße', 'passpassword12'),
(12, 0, 'userName13', 'George', 'Anderson', 0, 10117, 'Friedrichstraße', 'passpassword13'),
(13, 0, 'userName14', 'Aaron', 'Anderson', 0, 10117, 'Friedrichstraße', 'passpassword14'),
(14, 0, 'userName15', 'Peter', 'Ashwoon', 1, 10115, 'Jüdenstraße', 'passpassword15'),
(15, 0, 'userName16', 'Thomas', 'Dewalt', 2, 10117, 'Bernauer Straße', 'passpassword16'),
(16, 0, 'userName17', 'Roger', 'Lawless', 1, 10119, 'Friedrichstraße', 'passpassword17'),
(17, 0, 'userName18', 'Aaron', 'Cast', 1, 10115, 'Bernauer Straße', 'passpassword18'),
(18, 0, 'userName19', 'Nathan', 'Haworth', 2, 10115, 'Friedrichstraße', 'passpassword19'),
(19, 0, 'userName20', 'Walter', 'Deitz', 0, 10115, 'Bernauer Straße', 'passpassword20'),
(20, 0, 'userName21', 'Edward', 'Bongard', 1, 10119, 'Friedrichstraße', 'passpassword21'),
(21, 0, 'userName22', 'Tim', 'Lawicki', 1, 10119, 'Jüdenstraße', 'passpassword22'),
(22, 0, 'userName23', 'Edward', 'McCormack', 1, 10119, 'Jüdenstraße', 'passpassword23'),
(23, 0, 'userName24', 'Ty', 'Kassing', 1, 10119, 'Friedrichstraße', 'passpassword24'),
(24, 0, 'userName25', 'Hank', 'Cannon', 0, 10117, 'Bernauer Straße', 'passpassword25'),
(25, 0, 'userName26', 'Alex', 'Hesch', 1, 10119, 'Friedrichstraße', 'passpassword26'),
(26, 0, 'userName27', 'Jack', 'Orwig', 2, 10115, 'Jüdenstraße', 'passpassword27'),
(27, 0, 'userName28', 'Victor', 'Bateman', 1, 10115, 'Jüdenstraße', 'passpassword28'),
(28, 0, 'userName29', 'Jack', 'Hesch', 2, 10117, 'Jüdenstraße', 'passpassword29'),
(29, 0, 'userName30', 'Alex', 'McCormack', 0, 10119, 'Friedrichstraße', 'passpassword30'),
(30, 0, 'userName31', 'Hank', 'Miller', 1, 10115, 'Bernauer Straße', 'passpassword31'),
(31, 0, 'userName32', 'Adam', 'Lawicki', 2, 10117, 'Friedrichstraße', 'passpassword32'),
(32, 0, 'userName33', 'Aaron', 'Kassing', 1, 10117, 'Friedrichstraße', 'passpassword33'),
(33, 0, 'userName34', 'Fred', 'Hancock', 1, 10117, 'Jüdenstraße', 'passpassword34'),
(34, 0, 'userName35', 'Aaron', 'Deitz', 0, 10117, 'Bernauer Straße', 'passpassword35');

-- --------------------------------------------------------

--
-- Table structure for table `nsn_event`
--

CREATE TABLE `nsn_event` (
  `event_id` int(11) NOT NULL,
  `isDeleted` tinyint(1) DEFAULT 0,
  `event_name` varchar(30) DEFAULT NULL,
  `event_description` text DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT NULL,
  `organizer_id` int(11) DEFAULT NULL,
  `creation_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `nsn_event`
--

INSERT INTO `nsn_event` (`event_id`, `isDeleted`, `event_name`, `event_description`, `is_public`, `organizer_id`, `creation_time`) VALUES
(18, 0, 'g1', 'd1', 1, 1, '2019-12-10 12:57:35'),
(19, 0, 'g2', 'd2', 1, 1, '2019-12-10 12:57:50'),
(20, 0, 'g3', 'd3', 0, 1, '2019-12-10 12:58:03'),
(22, 0, 'g5', 'd5', 1, 1, '2019-12-10 13:38:47'),
(23, 0, 'this is a test', 'heeeeeeeeeeee', 0, 1, '2019-12-10 13:45:47'),
(24, 0, 'tea party', '--', 1, 1, '2019-12-10 15:47:54'),
(25, 0, 'heeeeeeelooooo', 'ahsdjadkas', 0, 11, '2019-12-10 16:18:12'),
(26, 0, 'lets know each other', 'hi', 0, 1, '2019-12-10 16:53:09'),
(27, 0, 'party', '--', 1, 11, '2019-12-12 10:44:54'),
(28, 0, 'party private', '-----', 0, 11, '2019-12-12 10:45:19'),
(29, 0, '2a5r test isa', '--', 0, 1, '2019-12-12 13:45:52'),
(30, 0, 'party fun', 'fun', 0, 1, '2019-12-12 15:25:23'),
(31, 0, '1234', '1234', 1, 1, '2019-12-12 15:25:49'),
(32, 0, '123', '123', 0, 1, '2019-12-12 15:25:59');

-- --------------------------------------------------------

--
-- Table structure for table `offer`
--

CREATE TABLE `offer` (
  `request_num` int(11) NOT NULL,
  `requester_id` int(11) NOT NULL,
  `supplier_id` int(11) NOT NULL,
  `isDeleted` tinyint(1) DEFAULT 0,
  `offered_time` datetime NOT NULL,
  `price` int(11) DEFAULT NULL,
  `offer_status` varchar(30) DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `offer`
--

INSERT INTO `offer` (`request_num`, `requester_id`, `supplier_id`, `isDeleted`, `offered_time`, `price`, `offer_status`) VALUES
(1, 1, 30, 0, '2019-12-11 13:57:45', 15, 'pending'),
(2, 1, 30, 0, '2019-12-12 12:50:43', 2147483647, 'pending'),
(3, 30, 1, 0, '2019-12-12 11:39:39', 2, 'accepted'),
(5, 1, 19, 0, '2019-12-12 15:29:58', 1000000, 'accepted');

-- --------------------------------------------------------

--
-- Table structure for table `post`
--

CREATE TABLE `post` (
  `post_id` int(11) NOT NULL,
  `isDeleted` tinyint(1) DEFAULT 0,
  `content` text DEFAULT NULL,
  `uploader_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `post_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `post`
--

INSERT INTO `post` (`post_id`, `isDeleted`, `content`, `uploader_id`, `group_id`, `post_time`) VALUES
(1, 0, 'hiiiiiiiiiiii', 1, NULL, '2019-12-08 20:06:22'),
(2, 0, 'please', 1, NULL, '2019-12-08 20:37:10'),
(3, 0, 'mY fIrSt POST :))))))))))))))', 11, NULL, '2019-12-09 10:33:55'),
(4, 0, 'Hey', 19, NULL, '2019-12-09 12:40:56'),
(5, 0, 'hello', 1, NULL, '2019-12-09 14:20:56'),
(6, 0, 'i like pizza', 1, NULL, '2019-12-09 14:23:48'),
(7, 0, 'post post', 1, NULL, '2019-12-09 14:26:38'),
(8, 0, 'hellllloooooooooo', 1, 1, '2019-12-09 16:20:05'),
(9, 0, 'shareeeeeeeeeeeeeeeeeeee', 1, 1, '2019-12-09 16:22:30'),
(10, 0, 'helooooooooooooooooooooooo22222222222', 1, 1, '2019-12-09 16:34:48'),
(11, 0, 'helllo guys', 1, 1, '2019-12-09 16:42:22'),
(12, 0, 'hello', 11, 8, '2019-12-10 00:49:15'),
(13, 0, 'hello again', 11, 8, '2019-12-10 00:50:38'),
(14, 0, 'hi Roger', 1, 8, '2019-12-10 00:51:30'),
(15, 0, 'ajdlaskfas', 2, NULL, '2019-12-10 14:34:24'),
(16, 0, 'hkdshfkhfef', 1, 9, '2019-12-10 15:51:00'),
(17, 0, 'hello there', 1, 13, '2019-12-12 13:42:02'),
(18, 0, 'hi tani', 1, 13, '2019-12-12 13:44:55'),
(19, 0, 'Hello', 11, 2, '2019-12-12 15:08:08'),
(20, 0, 'Hello', 1, 9, '2019-12-12 15:27:41'),
(21, 0, 'hi', 1, 11, '2019-12-13 03:29:05');

-- --------------------------------------------------------

--
-- Table structure for table `private_event`
--

CREATE TABLE `private_event` (
  `event_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `private_event`
--

INSERT INTO `private_event` (`event_id`) VALUES
(20),
(23),
(25),
(26),
(28),
(29),
(30),
(32);

-- --------------------------------------------------------

--
-- Table structure for table `public_event`
--

CREATE TABLE `public_event` (
  `event_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `public_event`
--

INSERT INTO `public_event` (`event_id`) VALUES
(18),
(19),
(22),
(24),
(27),
(31);

-- --------------------------------------------------------

--
-- Table structure for table `rates`
--

CREATE TABLE `rates` (
  `rater_id` int(11) NOT NULL,
  `rated_id` int(11) NOT NULL,
  `rate_value` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `rates`
--

INSERT INTO `rates` (`rater_id`, `rated_id`, `rate_value`) VALUES
(1, 11, 3),
(1, 17, 3),
(11, 1, 5),
(11, 19, 2),
(19, 1, 4),
(30, 17, 1);

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `reporter_id` int(11) NOT NULL,
  `reported_id` int(11) NOT NULL,
  `report_content` text DEFAULT NULL,
  `report_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `reports`
--

INSERT INTO `reports` (`reporter_id`, `reported_id`, `report_content`, `report_time`) VALUES
(1, 17, 'because', '2019-12-09 12:15:41'),
(19, 1, '', '2019-12-09 12:18:58');

-- --------------------------------------------------------

--
-- Table structure for table `service`
--

CREATE TABLE `service` (
  `request_num` int(11) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `service`
--

INSERT INTO `service` (`request_num`, `start_time`, `end_time`) VALUES
(7, '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(8, '1999-01-01 00:00:00', '1999-01-01 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `supply`
--

CREATE TABLE `supply` (
  `request_num` int(11) NOT NULL,
  `isDeleted` tinyint(1) DEFAULT 0,
  `supply_name` varchar(30) DEFAULT NULL,
  `supply_description` text DEFAULT NULL,
  `requested_time` datetime NOT NULL,
  `member_id` int(11) NOT NULL,
  `request_status` varchar(30) DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `supply`
--

INSERT INTO `supply` (`request_num`, `isDeleted`, `supply_name`, `supply_description`, `requested_time`, `member_id`, `request_status`) VALUES
(1, 0, 'btates', 'eh elly description wad7a btates', '2019-12-10 15:07:29', 1, 'pending'),
(2, 0, 'btates tany', 'nfs elly fo2', '2019-12-10 15:08:48', 1, 'pending'),
(3, 0, 'fakha2', 'hi', '2019-12-11 13:56:49', 30, 'resolved'),
(4, 0, '5odar', 'kteeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeer w gargeer', '2019-12-12 12:49:19', 1, 'pending'),
(5, 0, 'I want ay 7aga', 'ay 7aga is ay 7aga be 7ayth enaha tkoon ay 7aga w shokran', '2019-12-12 15:28:47', 1, 'resolved'),
(6, 0, '123', '12', '2019-12-13 23:21:20', 11, 'pending'),
(7, 0, 'hi', 'hielo', '2019-12-13 23:25:15', 11, 'pending'),
(8, 0, 'testing', 'time', '2019-12-13 23:26:26', 11, 'pending');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `adds`
--
ALTER TABLE `adds`
  ADD PRIMARY KEY (`adder_id`,`added_id`),
  ADD KEY `added_id` (`added_id`);

--
-- Indexes for table `blocks`
--
ALTER TABLE `blocks`
  ADD PRIMARY KEY (`blocker_id`,`blocked_id`),
  ADD KEY `blocked_id` (`blocked_id`);

--
-- Indexes for table `house`
--
ALTER TABLE `house`
  ADD PRIMARY KEY (`house_number`,`postal_code`,`street_name`);

--
-- Indexes for table `invitedtoprivateevent`
--
ALTER TABLE `invitedtoprivateevent`
  ADD PRIMARY KEY (`invited_id`,`event_id`),
  ADD KEY `event_id` (`event_id`);

--
-- Indexes for table `item`
--
ALTER TABLE `item`
  ADD PRIMARY KEY (`request_num`);

--
-- Indexes for table `joins`
--
ALTER TABLE `joins`
  ADD PRIMARY KEY (`group_id`,`member_id`),
  ADD KEY `member_id` (`member_id`);

--
-- Indexes for table `likes`
--
ALTER TABLE `likes`
  ADD PRIMARY KEY (`post_id`,`member_id`),
  ADD KEY `member_id` (`member_id`);

--
-- Indexes for table `message`
--
ALTER TABLE `message`
  ADD PRIMARY KEY (`message_time`,`sender_id`,`receiver_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `receiver_id` (`receiver_id`);

--
-- Indexes for table `nsncomment`
--
ALTER TABLE `nsncomment`
  ADD PRIMARY KEY (`post_id`,`commenter_id`,`comment_time`),
  ADD KEY `commenter_id` (`commenter_id`);

--
-- Indexes for table `nsngroup`
--
ALTER TABLE `nsngroup`
  ADD PRIMARY KEY (`group_id`),
  ADD KEY `creator_id` (`creator_id`);

--
-- Indexes for table `nsnmember`
--
ALTER TABLE `nsnmember`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `house_number` (`house_number`,`postal_code`,`street_name`);

--
-- Indexes for table `nsn_event`
--
ALTER TABLE `nsn_event`
  ADD PRIMARY KEY (`event_id`),
  ADD KEY `organizer_id` (`organizer_id`);

--
-- Indexes for table `offer`
--
ALTER TABLE `offer`
  ADD PRIMARY KEY (`request_num`,`requester_id`,`supplier_id`),
  ADD KEY `requester_id` (`requester_id`),
  ADD KEY `supplier_id` (`supplier_id`);

--
-- Indexes for table `post`
--
ALTER TABLE `post`
  ADD PRIMARY KEY (`post_id`),
  ADD KEY `uploader_id` (`uploader_id`),
  ADD KEY `group_id` (`group_id`);

--
-- Indexes for table `private_event`
--
ALTER TABLE `private_event`
  ADD PRIMARY KEY (`event_id`);

--
-- Indexes for table `public_event`
--
ALTER TABLE `public_event`
  ADD PRIMARY KEY (`event_id`);

--
-- Indexes for table `rates`
--
ALTER TABLE `rates`
  ADD PRIMARY KEY (`rater_id`,`rated_id`),
  ADD KEY `rated_id` (`rated_id`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`reporter_id`,`reported_id`),
  ADD KEY `reported_id` (`reported_id`);

--
-- Indexes for table `service`
--
ALTER TABLE `service`
  ADD PRIMARY KEY (`request_num`);

--
-- Indexes for table `supply`
--
ALTER TABLE `supply`
  ADD PRIMARY KEY (`request_num`,`member_id`),
  ADD KEY `member_id` (`member_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `nsngroup`
--
ALTER TABLE `nsngroup`
  MODIFY `group_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `nsnmember`
--
ALTER TABLE `nsnmember`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `nsn_event`
--
ALTER TABLE `nsn_event`
  MODIFY `event_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `post`
--
ALTER TABLE `post`
  MODIFY `post_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `supply`
--
ALTER TABLE `supply`
  MODIFY `request_num` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `adds`
--
ALTER TABLE `adds`
  ADD CONSTRAINT `adds_ibfk_1` FOREIGN KEY (`adder_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `adds_ibfk_2` FOREIGN KEY (`added_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `blocks`
--
ALTER TABLE `blocks`
  ADD CONSTRAINT `blocks_ibfk_1` FOREIGN KEY (`blocker_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `blocks_ibfk_2` FOREIGN KEY (`blocked_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `invitedtoprivateevent`
--
ALTER TABLE `invitedtoprivateevent`
  ADD CONSTRAINT `invitedtoprivateevent_ibfk_1` FOREIGN KEY (`invited_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `invitedtoprivateevent_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `nsn_event` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `item`
--
ALTER TABLE `item`
  ADD CONSTRAINT `item_ibfk_1` FOREIGN KEY (`request_num`) REFERENCES `supply` (`request_num`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `joins`
--
ALTER TABLE `joins`
  ADD CONSTRAINT `joins_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `nsngroup` (`group_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `joins_ibfk_2` FOREIGN KEY (`member_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `likes`
--
ALTER TABLE `likes`
  ADD CONSTRAINT `likes_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `likes_ibfk_2` FOREIGN KEY (`member_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `message`
--
ALTER TABLE `message`
  ADD CONSTRAINT `message_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `message_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `nsncomment`
--
ALTER TABLE `nsncomment`
  ADD CONSTRAINT `nsncomment_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `nsncomment_ibfk_2` FOREIGN KEY (`commenter_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `nsngroup`
--
ALTER TABLE `nsngroup`
  ADD CONSTRAINT `nsngroup_ibfk_1` FOREIGN KEY (`creator_id`) REFERENCES `nsnmember` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `nsnmember`
--
ALTER TABLE `nsnmember`
  ADD CONSTRAINT `nsnmember_ibfk_1` FOREIGN KEY (`house_number`,`postal_code`,`street_name`) REFERENCES `house` (`house_number`, `postal_code`, `street_name`) ON UPDATE CASCADE;

--
-- Constraints for table `nsn_event`
--
ALTER TABLE `nsn_event`
  ADD CONSTRAINT `nsn_event_ibfk_1` FOREIGN KEY (`organizer_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `offer`
--
ALTER TABLE `offer`
  ADD CONSTRAINT `offer_ibfk_1` FOREIGN KEY (`request_num`) REFERENCES `supply` (`request_num`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `offer_ibfk_2` FOREIGN KEY (`requester_id`) REFERENCES `supply` (`member_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `offer_ibfk_3` FOREIGN KEY (`supplier_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `post`
--
ALTER TABLE `post`
  ADD CONSTRAINT `post_ibfk_1` FOREIGN KEY (`uploader_id`) REFERENCES `nsnmember` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `post_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `nsngroup` (`group_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `private_event`
--
ALTER TABLE `private_event`
  ADD CONSTRAINT `private_event_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `nsn_event` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `public_event`
--
ALTER TABLE `public_event`
  ADD CONSTRAINT `public_event_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `nsn_event` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `rates`
--
ALTER TABLE `rates`
  ADD CONSTRAINT `rates_ibfk_1` FOREIGN KEY (`rater_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `rates_ibfk_2` FOREIGN KEY (`rated_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`reporter_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reports_ibfk_2` FOREIGN KEY (`reported_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `service`
--
ALTER TABLE `service`
  ADD CONSTRAINT `service_ibfk_1` FOREIGN KEY (`request_num`) REFERENCES `supply` (`request_num`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `supply`
--
ALTER TABLE `supply`
  ADD CONSTRAINT `supply_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `nsnmember` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
