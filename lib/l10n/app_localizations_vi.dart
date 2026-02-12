// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Quản lý Bảo hành Xe';

  @override
  String get navDashboard => 'Tổng quan';

  @override
  String get navWarranties => 'Yêu cầu bảo hành';

  @override
  String get navReports => 'Báo cáo';

  @override
  String get dashboardTitle => 'Tổng quan';

  @override
  String get warrantiesTitle => 'Yêu cầu bảo hành';

  @override
  String get reportsTitle => 'Báo cáo';

  @override
  String get quickActions => 'Thao tác nhanh';

  @override
  String get attachFile => 'Đính kèm file';

  @override
  String get summaryRequests => 'Yêu cầu bảo hành';

  @override
  String get summaryPending => 'Đang chờ duyệt';

  @override
  String get summaryInProgress => 'Đang xử lý';

  @override
  String get loginTitle => 'Đăng nhập';

  @override
  String get registerTitle => 'Tạo tài khoản';

  @override
  String get displayName => 'Tên hiển thị';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get createAccount => 'Tạo tài khoản';

  @override
  String get noAccount => 'Chưa có tài khoản? Đăng ký';

  @override
  String get haveAccount => 'Đã có tài khoản? Đăng nhập';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get vin => 'Số VIN';

  @override
  String get model => 'Dòng xe';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get issue => 'Lỗi phát sinh';

  @override
  String get description => 'Mô tả';

  @override
  String get upgradeCategory => 'Hạng mục nâng cấp';

  @override
  String get upgradeCategoryHint =>
      'VD: Camera 360, Âm thanh Harman Kardon, Bậc bước điện';

  @override
  String get upgradeDate => 'Ngày nâng cấp';

  @override
  String get requestWarranty => 'Yêu cầu bảo hành';

  @override
  String get addRequest => 'Tạo yêu cầu mới';

  @override
  String get attachmentLinks => 'Link đính kèm (Google Drive)';

  @override
  String get attachments => 'Hình ảnh & video';

  @override
  String get addAttachments => 'Tải file';

  @override
  String get addAttachmentsDrive => 'Tải lên Google Drive';

  @override
  String attachmentsSelected(Object count) {
    return '$count file đã chọn';
  }

  @override
  String get removeAttachment => 'Xóa file';

  @override
  String attachmentTooLarge(Object size) {
    return 'File quá lớn (tối đa $size MB).';
  }

  @override
  String get attachmentLoadFailed => 'Không đọc được file.';

  @override
  String get attachmentOpenFailed => 'Không mở được file.';

  @override
  String get googleDrive => 'Google Drive';

  @override
  String get firebaseStorage => 'Firebase Storage';

  @override
  String get googleDriveMissingClientId => 'Thiếu client ID Google Drive.';

  @override
  String get googleDriveSignInFailed => 'Đăng nhập Google Drive thất bại.';

  @override
  String get googleDriveUploadFailed => 'Upload Google Drive thất bại.';

  @override
  String get googleDriveShareFailed =>
      'Upload xong nhưng không chia sẻ được. Hãy kiểm tra quyền chia sẻ Drive.';

  @override
  String get requester => 'Người yêu cầu';

  @override
  String get viewOnly => 'Bạn không có quyền cập nhật trạng thái.';

  @override
  String get pending => 'Chờ duyệt';

  @override
  String get approved => 'Đã duyệt';

  @override
  String get rejected => 'Từ chối';

  @override
  String get inProgress => 'Đang xử lý';

  @override
  String get done => 'Hoàn tất';

  @override
  String daysLeft(Object days) {
    return 'Còn $days ngày';
  }

  @override
  String get daysLeftZero => 'Hết hạn hôm nay';

  @override
  String daysExpired(Object days) {
    return 'Đã hết hạn $days ngày';
  }

  @override
  String get change => 'Đổi';

  @override
  String get emptyState => 'Chưa có dữ liệu. Hãy tạo bản ghi mới.';

  @override
  String get comingSoon => 'Phần này đã sẵn sàng để kết nối dữ liệu Firebase.';

  @override
  String get navCatalog => 'Danh mục';

  @override
  String get catalogTitle => 'Danh mục';

  @override
  String get addModel => 'Thêm dòng xe';

  @override
  String get noModels => 'Chưa có dòng xe.';

  @override
  String get vinPrefixes => 'Tiền tố VIN';

  @override
  String get vinPrefixesHint =>
      'Nhập các tiền tố, phân cách bằng dấu phẩy hoặc xuống dòng.';

  @override
  String get vinPrefixesEmpty => 'Chưa có tiền tố VIN.';

  @override
  String get addCategory => 'Thêm hạng mục';

  @override
  String get noCategories => 'Chưa có hạng mục.';

  @override
  String get warrantyMonths => 'Bảo hành (tháng)';

  @override
  String get modelAutoDetected => 'Tự nhận biết từ VIN';

  @override
  String get modelNotFound => 'Không tìm thấy dòng xe theo VIN';

  @override
  String get selectModelForCategory => 'Chọn dòng xe để xem hạng mục';

  @override
  String get selectCategory => 'Chọn hạng mục nâng cấp';

  @override
  String get dealer => 'Đại lý';

  @override
  String get selectDealer => 'Chọn đại lý';

  @override
  String get addDealer => 'Thêm đại lý';

  @override
  String get months => 'tháng';

  @override
  String get dealersTitle => 'Đại lý';

  @override
  String get noDealers => 'Chưa có đại lý.';

  @override
  String get editDealer => 'Sửa đại lý';

  @override
  String get deleteDealer => 'Xóa đại lý';

  @override
  String get deleteDealerConfirm => 'Xóa đại lý này?';

  @override
  String get dealerInUse => 'Đại lý đang có yêu cầu bảo hành, không thể xóa.';

  @override
  String get editModel => 'Sửa dòng xe';

  @override
  String get deleteModel => 'Xóa dòng xe';

  @override
  String get deleteModelConfirm => 'Xóa dòng xe này và các hạng mục nâng cấp?';

  @override
  String get editCategory => 'Sửa hạng mục';

  @override
  String get deleteCategory => 'Xóa hạng mục';

  @override
  String get deleteCategoryConfirm => 'Xóa hạng mục này?';

  @override
  String get modelInUse => 'Dòng xe đang có yêu cầu bảo hành, không thể xóa.';

  @override
  String get categoryInUse =>
      'Hạng mục đang có yêu cầu bảo hành, không thể xóa.';
}
