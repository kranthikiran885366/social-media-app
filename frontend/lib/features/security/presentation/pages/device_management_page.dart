import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_colors.dart';
import '../../data/models/security_models.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';

class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<SecurityBloc>().add(LoadDevices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                floating: true,
                snap: true,
                expandedHeight: isTablet ? 120 : 100,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient.scale(0.1),
                    ),
                  ),
                  title: Text(
                    'Device Management',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: false,
                ),
                leading: Container(
                  margin: EdgeInsets.only(
                    left: isTablet ? 24 : 16,
                    top: isTablet ? 12 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                      size: isTablet ? 28 : 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: BlocConsumer<SecurityBloc, SecurityState>(
                  listener: (context, state) {
                    if (state is DeviceRemoved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Device removed successfully'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    } else if (state is DeviceTrusted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Device marked as trusted'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    } else if (state is SecurityError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is SecurityLoading) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                      );
                    }

                    if (state is DevicesLoaded) {
                      return _buildDevicesList(state.devices, isTablet);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDevicesList(List<Device> devices, bool isTablet) {
    if (devices.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.devices,
                  size: isTablet ? 80 : 64,
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: isTablet ? 24 : 16),
              Text(
                'No devices found',
                style: TextStyle(
                  fontSize: isTablet ? 22 : 18,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return Container(
          margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: isTablet ? 15 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isTablet ? 16 : 12),
                      decoration: BoxDecoration(
                        gradient: device.isCurrent 
                            ? AppColors.successGradient 
                            : device.isTrusted 
                                ? AppColors.primaryGradient 
                                : AppColors.primaryGradient.scale(0.3),
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                      child: Icon(
                        _getDeviceIcon(device.type),
                        size: isTablet ? 36 : 32,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: isTablet ? 20 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  device.name,
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (device.isCurrent)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 12 : 8,
                                    vertical: isTablet ? 6 : 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.successGradient,
                                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                  ),
                                  child: Text(
                                    'Current',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 14 : 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              if (device.isTrusted && !device.isCurrent)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 12 : 8,
                                    vertical: isTablet ? 6 : 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                  ),
                                  child: Text(
                                    'Trusted',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 14 : 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 8 : 4),
                          Text(
                            '${device.os} • ${device.browser}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 20 : 16),
                Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: isTablet ? 20 : 16,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: isTablet ? 8 : 4),
                          Text(
                            device.location,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 8 : 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: isTablet ? 20 : 16,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: isTablet ? 8 : 4),
                          Text(
                            'Last active ${timeago.format(device.lastActive)}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 8 : 4),
                      Row(
                        children: [
                          Icon(
                            Icons.computer,
                            size: isTablet ? 20 : 16,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: isTablet ? 8 : 4),
                          Text(
                            device.ipAddress,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!device.isCurrent) ...[
                  SizedBox(height: isTablet ? 20 : 16),
                  Row(
                    children: [
                      if (!device.isTrusted)
                        Expanded(
                          child: Container(
                            height: isTablet ? 56 : 48,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: isTablet ? 12 : 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                onTap: () {
                                  context.read<SecurityBloc>().add(TrustDevice(device.id));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.verified_user,
                                      color: Colors.white,
                                      size: isTablet ? 24 : 20,
                                    ),
                                    SizedBox(width: isTablet ? 12 : 8),
                                    Text(
                                      'Trust Device',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!device.isTrusted) SizedBox(width: isTablet ? 20 : 16),
                      Expanded(
                        child: Container(
                          height: isTablet ? 56 : 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.errorGradient,
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withOpacity(0.3),
                                blurRadius: isTablet ? 12 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                              onTap: () => _showRemoveDeviceDialog(device),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: isTablet ? 24 : 20,
                                  ),
                                  SizedBox(width: isTablet ? 12 : 8),
                                  Text(
                                    'Remove',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'mobile':
        return Icons.smartphone;
      case 'tablet':
        return Icons.tablet;
      case 'desktop':
        return Icons.computer;
      default:
        return Icons.device_unknown;
    }
  }

  void _showRemoveDeviceDialog(Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Device'),
        content: Text(
          'Are you sure you want to remove "${device.name}"? This will sign out the device and require re-authentication.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SecurityBloc>().add(RemoveDevice(device.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}