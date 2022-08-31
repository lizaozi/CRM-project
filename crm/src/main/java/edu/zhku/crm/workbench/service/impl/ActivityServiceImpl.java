package edu.zhku.crm.workbench.service.impl;

import edu.zhku.crm.workbench.domain.Activity;
import edu.zhku.crm.workbench.mapper.ActivityMapper;
import edu.zhku.crm.workbench.mapper.ActivityRemarkMapper;
import edu.zhku.crm.workbench.service.ActivityService;
import edu.zhku.crm.workbench.web.controller.ActivityController;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

/**
 * @author lzw
 * @date 2022/4/21
 * @description
 */
@Service("activityService")
public class ActivityServiceImpl implements ActivityService {

    @Resource
    private ActivityMapper activityMapper;
    @Resource
    private ActivityRemarkMapper activityRemarkMapper;

    @Override
    public int saveCreateActivity(Activity activity) {
        return activityMapper.insertActivity(activity);
    }

    @Override
    public List<Activity> queryActivityByConditionForPage(Map<String, Object> map) {
        return activityMapper.selectActivityByConditionForPage(map);
    }

    @Override
    public int queryActivityOfCountByCondition(Map<String, Object> map) {
        return activityMapper.selectCountOfActivityByCondition(map);
    }

    @Override
    public void deleteActivityByIds(String[] ids) {
        activityMapper.deleteActivityByIds(ids);
        activityRemarkMapper.deleteActivityRemarkByActivityIds(ids);
    }

    @Override
    public Activity queryActivityById(String id) {
        return activityMapper.selectActivityById(id);
    }

    @Override
    public int saveEditActivity(Activity activity) {
        return activityMapper.updateActivity(activity);
    }

    @Override
    public List<Activity> queryAllActivities() {
        return activityMapper.selectAllActivities();
    }

    @Override
    public List<Activity> queryActivityByIdsForExport(String[] ids) {
        return activityMapper.selectActivityByIdsForExport(ids);
    }

    @Override
    public int saveCreateActivityByList(List<Activity> activityList) {
        return activityMapper.insertActivityByList(activityList);
    }

    @Override
    public Activity queryActivityByIdForDetail(String id) {
        return activityMapper.selectActivityByIdForDetail(id);
    }

    @Override
    public List<Activity> queryActivityByClueIdForDetail(String clueId) {
        return activityMapper.selectActivityByClueIdForDetail(clueId);
    }

    @Override
    public List<Activity> queryActivityForDetailByNameClueId(Map<String, Object> map) {
        return activityMapper.selectActivityForDetailByNameClueId(map);
    }

    @Override
    public List<Activity> queryActivityForConvertByNameClueId(Map<String, Object> map) {
        return activityMapper.selectActivityForConvertByNameClueId(map);
    }

    @Override
    public List<Activity> queryActivityByName(String name) {
        return activityMapper.selectActivityByName(name);
    }

    @Override
    public List<Activity> queryActivityByContactsIdForDetail(String contactsId) {
        return activityMapper.selectActivityByContactsIdForDetail(contactsId);
    }
}
