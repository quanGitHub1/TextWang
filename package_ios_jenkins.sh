#!/bin/sh


#计时
SECONDS=0

#假设脚本放置在与项目相同的路径下
project_path=$(pwd)
#指定项目的scheme名称
scheme="textOne"
#指定打包所使用的provisioning profile名称
provisioning_profile="weClassroomDis"
#指定项目地址
workspace_path="$project_path/textOne.xcworkspace"

EXPORT_OPTIONS_PLIST=${project_path}/exportOptions/exportOptions.plist

#是否是pod项目
isPod=1
#是否是workspace工程，一般跟isPod一样
isWorkspace=1

#蒲公英uKey，从蒲公英网站上获取
pgyUkey="0a41f5f761083057ef13c0f4bc7b0430"
#蒲公英apiKey
pgyApiKey="d61715a8dc46a57ff7a0ed9c7954b6e6"
#蒲公英上传url
pgyUploadUrl="https://www.pgyer.com/apiv1/app/upload"
#蒲公英安装密码
pgyInstallPassword=""

#指定要打包的配置名
configuration="Release"
#取当前时间字符串添加到文件结尾
now=$(date +"%Y_%m_%d_%H_%M_%S")
#指定输出路径
output_path="${project_path}/build"
#指定输出归档文件地址
archive_path="$output_path/app_${now}.xcarchive"
#指定输出ipa地址
#ipa_path="$output_path/app_${now}.ipa"

ipa_path="$output_path"


#获取执行命令时的时拿到分支名称
chooseBranch="$1"


#输出设定的变量值
echo "workspace path: ${workspace_path}"
echo "archive path: ${archive_path}"
echo "ipa path: ${ipa_path}"
echo "profile: ${provisioning_profile}"



#cd到工程根目录
cd $project_path
#pod 安装
pod install

#build
#判断是workspace还是project，执行不同的参数命令
workspaceOrProjectParam="project"
if [ $isWorkspace = 1 ];then
workspaceOrProjectParam="workspace"
fi
#先清空前一次build
xcodebuild clean -${workspaceOrProjectParam} ${workspace_path} -scheme ${scheme} -configuration ${configuration}
#清空之前的打包
rm -rf ${output_path}

#修改build号
originBuildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${info_plist_path}")


#build号设为当天日期，此处用 Y.md.HMS 作为build号，例如 2016年12月15日14:28:21,则build号为 2016.1215.142821
buildNumber=$(date +"%Y.%m%d.%H%M%S")
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${info_plist_path}"
echo "build number increase to ${buildNumber}"

#修改包名
originDisplayName=$(/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" "${info_plist_path}")
newDisplayName="${originDisplayName}(企业版)"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $newDisplayName" "${info_plist_path}"
echo "displayName change to ${newDisplayName}"

#根据指定的项目、scheme、configuration与输出路径打包出archive文件
xcodebuild -${workspaceOrProjectParam} ${workspace_path} -scheme ${scheme} -configuration ${configuration} archive -archivePath ${archive_path}

#使用指定的provisioning profile导出ipa
xcodebuild -exportArchive -archivePath ${archive_path} -exportPath ${ipa_path} -exportOptionsPlist ${EXPORT_OPTIONS_PLIST}

#包displayName改回去
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $originDisplayName" "${info_plist_path}"
echo "displayName change to ${originDisplayName}"

#build号改回去
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $originBuildNumber" "${info_plist_path}"
echo "buildNumber change to ${originBuildNumber}"

#在Finder中打开
open ${output_path}


ipaname=textOne.ipa

ipapath="${project_path}/build"





#上传到fir，需要安装fir cli
# fir publish ${ipa_path} -T fir_token -c "${commit_msg}"

#上传到蒲公英
#if [ $isUpload = y ];then
#echo "正在上传到蒲公英..."
#curl -F "file=@${ipa_path}/WCRGroupClass.ipa" -F "uKey=${pgyUkey}" -F "_api_key=${pgyApiKey}" -F "password=${pgyInstallPassword}" -F "updateDescription=${chooseBranch}" ${pgyUploadUrl}
#echo ""
#fi

#输出总用时
echo "Finished. Total time: ${SECONDS}s"
#输出设定的变量值
echo "workspace path: ${workspace_path}"
echo "archive path: ${archive_path}"
echo "ipa path: ${ipa_path}"
echo "profile: ${provisioning_profile}"
echo "chooseBranch: $1"

echo  "ipapath"
