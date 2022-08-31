package edu.zhku.crm.workbench.service;

import edu.zhku.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

/**
 * @author lzw
 * @date 2022/4/21
 * @description
 */
public interface ActivityService {
    /**
     * 创建市场活动
     * @param activity
     * @return
     */
    int saveCreateActivity(Activity activity);

    List<Activity> queryActivityByConditionForPage(Map<String,Object> map);

    int queryActivityOfCountByCondition(Map<String,Object> map);

    void deleteActivityByIds(String[] ids);

    Activity queryActivityById(String id);

    int saveEditActivity(Activity activity);

    List<Activity> queryAllActivities();

    List<Activity> queryActivityByIdsForExport(String[] ids);

    int saveCreateActivityByList(List<Activity> activityList);

    Activity queryActivityByIdForDetail(String id);

    List<Activity> queryActivityByClueIdForDetail(String clueId);

    List<Activity> queryActivityForDetailByNameClueId(Map<String,Object> map);

    List<Activity> queryActivityForConvertByNameClueId(Map<String,Object> map);

    List<Activity> queryActivityByName(String name);

    List<Activity> queryActivityByContactsIdForDetail(String contactsId);
}
