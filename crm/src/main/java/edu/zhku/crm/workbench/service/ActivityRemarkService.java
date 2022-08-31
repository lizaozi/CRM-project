package edu.zhku.crm.workbench.service;

import edu.zhku.crm.workbench.domain.ActivityRemark;

import java.util.List;

/**
 * @author lzw
 * @date 2022/4/28
 * @description
 */
public interface ActivityRemarkService {
    List<ActivityRemark> queryActivityRemarkByActivityIdForDetail(String activityId);

    int saveCreateActivityRemark(ActivityRemark remark);

    int deleteActivityRemarkById(String id);

    int saveEditActivityRemark(ActivityRemark remark);
}
