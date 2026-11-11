import '../features/position_search/data/models/job_position_model.dart';

/// Reference catalog written to Firestore the first time an admin signs in.
const List<JobPositionModel> jobCatalog = [
  JobPositionModel(id: 'pos_001', title: 'Flutter Developer', category: 'Mobile', relatedSkills: ['Flutter', 'Dart', 'Firebase'], searchCount: 150),
  JobPositionModel(id: 'pos_002', title: 'Android Developer', category: 'Mobile', relatedSkills: ['Kotlin', 'Java', 'Android SDK'], searchCount: 120),
  JobPositionModel(id: 'pos_003', title: 'iOS Developer', category: 'Mobile', relatedSkills: ['Swift', 'SwiftUI', 'Xcode'], searchCount: 100),
  JobPositionModel(id: 'pos_004', title: 'Software Engineer', category: 'General', relatedSkills: ['DSA', 'System Design', 'Problem Solving'], searchCount: 200),
  JobPositionModel(id: 'pos_005', title: 'Mobile App Developer', category: 'Mobile', relatedSkills: ['Flutter', 'React Native', 'Kotlin'], searchCount: 130),
  JobPositionModel(id: 'pos_006', title: 'Backend Developer', category: 'Backend', relatedSkills: ['Node.js', 'Python', 'REST APIs', 'Databases'], searchCount: 180),
  JobPositionModel(id: 'pos_007', title: 'Frontend Developer', category: 'Frontend', relatedSkills: ['React', 'Vue.js', 'HTML', 'CSS', 'JavaScript'], searchCount: 170),
  JobPositionModel(id: 'pos_008', title: 'UI/UX Designer', category: 'Design', relatedSkills: ['Figma', 'Adobe XD', 'Prototyping'], searchCount: 90),
  JobPositionModel(id: 'pos_009', title: 'Python Developer', category: 'Backend', relatedSkills: ['Python', 'Django', 'FastAPI', 'Flask'], searchCount: 160),
  JobPositionModel(id: 'pos_010', title: 'Java Developer', category: 'Backend', relatedSkills: ['Java', 'Spring Boot', 'Hibernate'], searchCount: 140),
  JobPositionModel(id: 'pos_011', title: 'DevOps Engineer', category: 'Infrastructure', relatedSkills: ['Docker', 'Kubernetes', 'CI/CD', 'AWS'], searchCount: 110),
  JobPositionModel(id: 'pos_012', title: 'Data Scientist', category: 'Data', relatedSkills: ['Python', 'Machine Learning', 'TensorFlow', 'SQL'], searchCount: 95),
  JobPositionModel(id: 'pos_013', title: 'Full Stack Developer', category: 'General', relatedSkills: ['React', 'Node.js', 'MongoDB', 'Express'], searchCount: 190),
  JobPositionModel(id: 'pos_014', title: 'React Developer', category: 'Frontend', relatedSkills: ['React', 'Redux', 'TypeScript', 'Next.js'], searchCount: 175),
  JobPositionModel(id: 'pos_015', title: 'Cloud Architect', category: 'Infrastructure', relatedSkills: ['AWS', 'GCP', 'Azure', 'Terraform'], searchCount: 70),
];
